module ProfilesHelper
  # Labels per docs/05-formulas.md §2 (TDEE activity factor).
  def activity_options
    [
      ["Сидячая работа, нет тренировок", "1.2"],
      ["1–3 тренировки в неделю", "1.375"],
      ["3–5 тренировок в неделю", "1.55"],
      ["6–7 тренировок или физический труд", "1.725"]
    ]
  end
end
