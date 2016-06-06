/* .p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        --/--/2009 madiyar
 * BASES
        BANK
 * CHANGES
*/

def var skp as int format '99' label 'день '.
def var bkp as int format '99' label 'месяц'.
def var knp as int format '9999' label 'год  '.
def output parameter v-r as char.
form skp bkp knp with frame pp side-label row 5   overlay
    1  COLUMN  centered.

if v-r ne '' then do :
    skp = int(entry(1,v-r,',')).
    bkp = int(entry(2,v-r,',')).
    knp = int(entry(3,v-r,',')).
end.

displ skp bkp knp with frame pp. pause 0.

update skp  validate(
   skp < 32,
  'не правильно введен день!') with frame pp.
update bkp validate(
   bkp < 13,
  'не правильно введен месяц!') with frame pp.
update knp /*validate(
   knp > 2010,
  'не правильно введен год!')*/ with frame pp.
if bkp = 2 and skp > 29 then do:
    message "Ошибка в дате!" view-as alert-box.
    return.
end.
v-r = string(skp, "99") + '/' + string(bkp, "99") + '/' + string(knp, "9999").

hide frame pp.