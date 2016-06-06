/* findofc.p
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
*/

/*  finglog.p AGA 13/01/97 - "видно в понедельник их мама pодила".
РЕЦЕПТ ПРИМЕHЕHИЯ: для поиска oficer'ов заpегиситpиpованных в PLATON'е
Секpет пpиготовления:
взята пpогpамма  findcifg.p совеpшенно ничейная пpогpамма ( но
я то подозpеваю, что она чья-то, а именно pnp), тщетельно и твоpчески
доpаботана и пеpеpаботана и вот оно твоpение пpед Вами.
Кто не спpятался - я не виноват!

*/

DEF var v-name LIKE ofc.name.
DEF var f-name LIKE ofc.name.
DEF var lenv AS int.
DEF var lenf AS int.
DEF var i AS int.
DEF var i0 AS int.
DEF var ff AS log.
v-name = "".
REPEAT:
  UPDATE v-name LABEL "Что искать в ФИО? " WITH FRAME aaa.
  DISPLAY  " Ждите ... " i0 FORMAT "zzzzzz"
    NO-LABEL WITH COLUMN 40 row 2 WITH FRAME aac.
  PAUSE 0.
  v-name = TRIM(v-name).
  lenv = length(v-name).
  i0 = 0.
  FOR EACH ofc :
    DISPLAY i0 FORMAT "zzzzzz" WITH FRAME aac.
    i0 = i0 + 1.
    f-name = TRIM(name).
    lenf = length(f-name).
    i = 0.
    ff = FALSE.
    REPEAT :
      i = i + 1.
      IF i + lenv - 1 > lenf THEN
      LEAVE.
      IF substr(f-name,i,lenv) = v-name THEN
      DO:
        ff = TRUE.
        LEAVE.
      END.
    END.
    IF ff THEN
    DISPLAY ofc.ofc LABEL "Oficer" ofc.name LABEL " Description " FORMAT "x(30)" .
    NEXT .
    IF NOT AVAILABLE ofc THEN
    LEAVE.
  END.
  HIDE FRAME aac.
END.
