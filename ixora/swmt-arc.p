/* swmt-arc.p
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
        15/10/03 sasco разбор 72 поля для Рублей
*/

/* KOVAL Поиск введенных макетов из архива */

def shared temp-table swin like swbody 
 field mandatory as char format "x(2)"
 field descr     as char format "x(30)"
 field feature   as char format "x(12)"
 field length    like swfield.length
 index ind is primary swfield type.   /* Размер поля             */

def shared var s-remtrz like remtrz.remtrz. /* sasco */

def buffer tswbody  for swbody.
def buffer tswbody2 for swbody.
def buffer tswout  for swout.

def var q-t     like swbody.content[1] init "".
def var q-c     like swbody.content[1] init "".
def var q-mt    like swout.mt init "100".
def var q-d1    like swout.credate   init ?.
def var q-d2    like swout.credate   init ?.

def temp-table a-remtrz
    field a-remtrz as char format "x(12)".

def frame ff
 "Поле макета"  q-t     format "x(2)"      skip
 "Содержимое:"  q-c     format "x(35)"     skip
 "Тип макета:"  q-mt    format "x(3)"     skip
 "Дата с     "  q-d1    format "99.99.99"  skip 
 "по         "  q-d2    format "99.99.99"  skip(1)
 with overlay centered title "Условия поиска" no-labels. 

find remtrz where remtrz.remtrz = s-remtrz no-lock no-error. /* sasco - для дальнейшего поиска Рублей */
find crc where crc.crc = remtrz.tcrc no-lock no-error.

 assign q-d1 = today - 30 
        q-d2 = today.

 update q-t
        q-c
        q-mt
        q-d1 q-d2 with frame ff.

if q-t="" then q-t="*".
q-c = "*" + q-c + "*".

if q-d1 = ? then q-d1 = 01/01/00.
if q-d2 = ? then q-d2 = 12/31/25.

for each tswout where tswout.mt=q-mt and tswout.credate >= q-d1 and tswout.credate <= q-d2 no-lock.

        for each tswbody where tswbody.rmz = tswout.rmz and tswbody.swfield matches q-t and 
                tswbody.content[1] + tswbody.content[2] + tswbody.content[3] +
                tswbody.content[4] + tswbody.content[5] + tswbody.content[6] 
                matches q-c no-lock break by tswbody.rmz.
                if first-of(tswbody.rmz) then do:
                        create a-remtrz.
                        a-remtrz.a-remtrz = tswbody.rmz.
                end.
        end.
end.

def frame info 
 tswbody.type       format "x(1)"  
 tswbody.content[1] format "x(35)" skip
 tswbody.content[2] format "x(35)" skip
 tswbody.content[3] format "x(35)" skip
 tswbody.content[4] format "x(35)" skip
 tswbody.content[5] format "x(35)" skip
 tswbody.content[6] format "x(35)"  
 with no-label overlay row 1 column 15 size 60 by 19.

/* swin.mandatory  format "x(1)"  no-label */


DEFINE QUERY q2 FOR a-remtrz.
DEFINE QUERY q3 FOR tswbody.

def browse b2 
    query q2 no-lock
    display 
        a-remtrz.a-remtrz format "x(11)"
        with 18 down no-labels no-box.

def browse b3
    query q3 no-lock
    disp tswbody.swfield    format "x(2)"  no-label
         tswbody.type       format "x(1)"  no-label 
         tswbody.content[1] format "x(35)" no-label 
         tswbody.content[2] format "x(35)" no-label
         tswbody.content[3] format "x(35)" no-label 
         tswbody.content[4] format "x(35)" no-label
         tswbody.content[5] format "x(35)" no-label
         tswbody.content[6] format "x(35)" no-label
         with size 65 by 19 title "Swift-Макет"
         SEPARATORS NO-ASSIGN.

DEF Frame f2
    b2 at x 1 y 8
    b3 at x 112 y 1
    with size 80 by 19 no-box.

/*DEF Frame f3
    b3 
    with row 16 column 1 no-box.*/

on value-changed of b2 IN FRAME f2 do:
 open query q3 for each tswbody where tswbody.rmz = a-remtrz.a-remtrz by tswbody.swfield.
 b3:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
/* ENABLE all with frame f3. 
 apply "value-changed" to b3 in frame f2.*/
end.

on return of b2 in frame f2 do: 
 for each tswbody2 no-lock where tswbody2.rmz = a-remtrz.a-remtrz.
 /* Некопируемые поля */ 
  if tswbody2.swfield = 'DS' or tswbody2.swfield = '32' or tswbody2.swfield = '53' or tswbody2.swfield = '20' or tswbody2.swfield = '50' or tswbody2.swfield = '21' or tswbody2.swfield = '33' or tswbody2.swfield = '71' then next.
  find first swin where swin.swfield = tswbody2.swfield no-error.
  if avail swin then do:
                     /* sasco : для Рублей в 72 поле где не проставлено: сделаем то что надо :-) */
                     if crc.crc = 4 and tswbody2.swfield = '72' then 
                     do:
                        /* если уже соотв. формату /DAS/ то просто скопируем недостающее */
                        if substr (tswbody2.content[1], 1, 5) = '/DAS/' then 
                        assign swin.content[2] = tswbody2.content[2]
                               swin.content[3] = tswbody2.content[3]
                               swin.content[4] = tswbody2.content[4]
                               swin.content[5] = tswbody2.content[5]
                               swin.content[6] = tswbody2.content[6]
                               swin.type       = tswbody2.type.
                        else /* если старый формат 72 поля, то все надо "сдвинуть" вниз */
                        assign swin.content[2] = tswbody2.content[1]
                               swin.content[3] = tswbody2.content[2]
                               swin.content[4] = tswbody2.content[3]
                               swin.content[5] = tswbody2.content[4]
                               swin.content[6] = tswbody2.content[5]
                               swin.type       = tswbody2.type.
                     end.
                     else /* обычное поле */                    
                     assign swin.content[1] = tswbody2.content[1]
                            swin.content[2] = tswbody2.content[2]
                            swin.content[3] = tswbody2.content[3]
                            swin.content[4] = tswbody2.content[4]
                            swin.content[5] = tswbody2.content[5]
                            swin.content[6] = tswbody2.content[6]
                            swin.type       = tswbody2.type.
  end.
 end.
 apply "endkey" to frame f2.
 hide frame f2.
end.  
                    
on return of b3 in frame f2 do: 

 /* Некопируемые поля */ 
  if tswbody.swfield = 'DS' or tswbody.swfield = '32' or tswbody.swfield = '53' or tswbody.swfield = '20' or tswbody.swfield = '50' or tswbody.swfield = '21' or tswbody.swfield = '33' or tswbody.swfield = '71' then return.

  find first swin where swin.swfield = tswbody.swfield no-error.
  if avail swin then do:
                     /* sasco : для Рублей в 72 поле где не проставлено: сделаем то что надо :-) */
                     if crc.crc = 4 and tswbody.swfield = '72' then 
                     do:
                        /* если уже соотв. формату /DAS/ то просто скопируем недостающее */
                        if substr (tswbody2.content[1], 1, 5) = '/DAS/' then 
                        assign swin.content[2] = tswbody.content[2]
                               swin.content[3] = tswbody.content[3]
                               swin.content[4] = tswbody.content[4]
                               swin.content[5] = tswbody.content[5]
                               swin.content[6] = tswbody.content[6]
                               swin.type       = tswbody.type.
                        else /* если старый формат 72 поля, то все надо "сдвинуть" вниз */
                        assign swin.content[2] = tswbody.content[1]
                               swin.content[3] = tswbody.content[2]
                               swin.content[4] = tswbody.content[3]
                               swin.content[5] = tswbody.content[4]
                               swin.content[6] = tswbody.content[5]
                               swin.type       = tswbody.type.
                     end.
                     else /* обычное поле */ 
                     assign swin.content[1] = tswbody.content[1]
                            swin.content[2] = tswbody.content[2]
                            swin.content[3] = tswbody.content[3]
                            swin.content[4] = tswbody.content[4]
                            swin.content[5] = tswbody.content[5]
                            swin.content[6] = tswbody.content[6]
                            swin.type       = tswbody.type.
  end.
 apply "endkey" to frame f2.
 hide frame f2.
end.
 
open query q2 for each a-remtrz.

if num-results("q2")=0 then do:
    MESSAGE "Записи не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok.
    return.                 
end.

b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame f2.
apply "value-changed" to b2 in frame f2.
WAIT-FOR endkey of frame f2.

hide frame f2.
