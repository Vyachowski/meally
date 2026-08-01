# 07 — Стек и окружение

## Состав

```
Rails 8.x
├── Hotwire — Turbo Frames / Turbo Streams / Stimulus
├── PWA — встроенные генераторы Rails 8 (манифест + service worker)
├── SQLite + Solid Queue / Solid Cache / Solid Cable   (ADR-006)
├── rails g authentication — встроенная, без Devise
├── TailwindCSS
├── Minitest — тесты
└── Kamal — деплой
```

## Почему так

- **Hotwire вместо SPA** — ADR-005
- **SQLite** — ADR-006
- **Встроенная аутентификация** — при одном пользователе Devise избыточен
- **Minitest** — идёт из коробки, не тащить RSpec ради синтаксиса

## Окружение

| | |
|---|---|
| Ruby | 3.3+ |
| Локальный запуск | `bin/dev` |
| Тесты | `bin/rails test` |
| Валидатор контента | `bin/rails content:validate` |
| Заливка контента | `bin/rails content:import` |

## PWA-требования

- Устанавливается на домашний экран Android/iOS
- Открывается без адресной строки (`display: standalone`)
- Оболочка и текущий план кэшируются service worker'ом
- Вкладки «Покупки» и «Готовка» открываются без сети
- Wake Lock во время пошаговой готовки

Оффлайн-**запись** с синхронизацией — не в v1.

## Деплой

VPS + Kamal. HTTPS через Let's Encrypt.

Бэкап: cron, копирование файла SQLite в объектное хранилище раз в сутки. Проверить восстановление хотя бы один раз — бэкап без проверенного восстановления не бэкап.

## Что не тащим в v1

Redis · Postgres · Docker Compose для локальной разработки · Sidekiq · Devise · RSpec · любой JS-фреймворк · CI сложнее «прогнать тесты»
