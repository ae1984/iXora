/* vcdngtd.p
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

/* vcdngtd.p Валютный контроль
   Вызов редактирования ГТД

   18.10.2002 nadejda создан
    11.03.2011 damir - перекомпиляция в связи с добавлением нового поля opertyp
*/

def new shared var s-vcdoctypes as char.
def new shared var s-dnvid as char init "g".

s-vcdoctypes = "".
for each codfr where codfr.codfr = "vcdoc" and index(s-dnvid, codfr.name[5]) > 0 no-lock:
  s-vcdoctypes = s-vcdoctypes + codfr.code + ",".
end.

run vcdngtds.

