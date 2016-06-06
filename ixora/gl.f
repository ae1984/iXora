/* gl.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        24.05.10 marinav - увеличено поле наименование 
*/

/* gl.f
*/
/*22/11/02 - nataly 
добавлена проверка на длину счета ГК*/

form "Счет#      :" gl.gl validate(length(string(gl.gl)) = 6 or gl.gl = 0, "Длина счета ГК <> 6")  
     "Валюта:" at 25 gl.crc
                              "Начало года:" at 45 vyst skip
     "Наименование:" gl.des format "x(62)" skip
     "Краткое имя:" gl.sname format "x(40)" skip 
     "     Дебет :" at 45 vydr skip
     "Тип счета  :" gl.type   "Счет дохода:" at 25 gl.gl1
                                  "Кредит :" at 49 vycr skip
     "Реверс.счет:" gl.revgl  "Парн.счет:" at 25 gl.autogl
                               "Начало мес:" at 46 vmst skip
     "Накопит.(ДБ):" gl.glacr 
      validate(can-find(b-gl where b-gl.gl eq glacr) or gl.glacr eq 0, "")
     "Накопит.(КР):" at 25  gl.glacrdb 
      validate(can-find(b-gl where b-gl.gl eq glacrdb) or gl.glacrdb eq 0, "") 
                    skip
     "Тип субсчета:" gl.subled "Уровень:" 
                                       at 25 gl.level format "99" 
                              "     Дебет :" at 45 vmdr skip
     "Статус     :" gl.sts    "Код  :" at 25 gl.code
                              "     Кредит:" at 45 vmcr skip
                              "Группа:" at 25 gl.grp skip
                              "Начало дня :" at 45 vtst skip
                              "      Дебет:" at 45 vtdr skip
                              "     Кредит:" at 45 vtcr skip
                              "  Остаток  :" at 45 vtbl skip(1)
     "Сумма оборотов за месяц :" at 32 vttl  skip
     "Средний оборот за месяц :" at 32 vtavg skip
     with row 3 no-label overlay frame gl.

 form "  1" vtot[1] vavg[1] skip
      "  2" vtot[2] vavg[2] skip
      "  3" vtot[3] vavg[3] skip
      "  4" vtot[4] vavg[4] skip
      "  5" vtot[5] vavg[5] skip
      "  6" vtot[6] vavg[6] skip
      "  7" vtot[7] vavg[7] skip
      "  8" vtot[8] vavg[8] skip
      "  9" vtot[9] vavg[9] skip
      " 10" vtot[10] vavg[10] skip
      " 11" vtot[11] vavg[11] skip
      " 12" vtot[12] vavg[12] skip
      with row 4 centered no-label overlay top-only frame accm.
