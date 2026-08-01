# 03 — Доменная модель

Обновлено под ADR-004 (фиксированная ротация).

## Схема

```ruby
# --- Пользователь и замеры ---

User
  email_address, password_digest
  birth_date, sex, height_cm, activity_factor

Measurement
  user, taken_on, kind (:weight | :waist), value
  # вес в кг, талия в см
  # одна таблица, чтобы дешево добавить бедра/грудь/шею

# --- Цель ---

Goal
  user, status (:active | :achieved | :abandoned)
  primary_metric (:waist | :weight)      # см. ADR-002
  start_weight_kg, start_waist_cm
  target_weight_kg, target_waist_cm
  started_on
  weekly_rate_kg                          # 0.3..0.4, см. ADR-003
  tdee_kcal, target_kcal
  protein_g, fat_g, carbs_g

# --- Контент ---

Ingredient
  name, unit (:g | :ml | :pcs)
  kcal_per_100, protein_per_100, fat_per_100, carbs_per_100
  shop_section (:produce | :meat | :dairy | :grains | :frozen | :pantry)
  gluten_risk (:none | :check_label | :contains)
  pack_size_g              # округление в списке покупок
  avg_piece_weight_g       # конвертация pcs -> g
  price_estimate           # оценка суммы чека

Recipe
  name
  meal_slot (:breakfast | :lunch | :snack | :dinner)
  cook_method (:one_pot | :sheet_pan | :no_cook | :overnight)
  active_minutes, passive_minutes
  storage_days, freezable
  servings_per_batch

RecipeIngredient
  recipe, ingredient, quantity

RecipeStep
  recipe, position, text, timer_seconds

# --- Ротация ---

Rotation
  name, goal_type, base_kcal, flavor_profile, order_index

RotationMeal
  rotation, meal_slot, recipe
  # ровно 4 записи на ротацию, day_index отсутствует

CookSession                # смерженный сценарий готовки
  rotation, position, title, covers_days

CookSessionStep
  cook_session, position, text, timer_seconds, recipe (nullable)

# --- Состояние ---

WeekPlan
  user, rotation, starts_on
  scale                    # target_kcal / base_kcal
  shopping_done_at

CookSessionCompletion
  week_plan, cook_session, completed_at

ShoppingItem               # материализован, см. ADR-007
  week_plan, ingredient, quantity, unit
  purchased_at, already_at_home
```

## Инварианты

1. У `User` одновременно **не более одной** `Goal` со статусом `:active`.
2. У `Rotation` ровно **4** `RotationMeal` — по одной на каждый `meal_slot`.
3. `Recipe.meal_slot` — единственное значение, не массив (следствие ADR-004: блюдо привязано к своему слоту).
4. `WeekPlan.scale` ограничен диапазоном **0.7–1.4**. Вне диапазона — ошибка валидации, нужна другая ротация.
5. `ShoppingItem` создаются транзакционно вместе с `WeekPlan`.
6. Все `Ingredient` в активных рецептах имеют `gluten_risk != :contains`.

## Что специально отсутствует

| Не заводим | Почему |
|---|---|
| `MealCompletion` | ADR-001 |
| `day_index` в плане | ADR-004, меню одинаковое все 7 дней |
| `Recipe#gluten_free` | Все рецепты безглютеновые по определению; проверка через ингредиенты |
| `Recipe#batchable` | В v1 все рецепты batchable, флаг избыточен |
| Таблица пользовательских правок рецептов | Кастомизации нет |

## Заметки по производительности

При одном пользователе не важно, но чтобы не переписывать:

- Агрегация списка покупок — один проход по `RotationMeal → RecipeIngredient`, группировка по `ingredient_id`
- Скользящее среднее веса — оконная функция, не N+1
