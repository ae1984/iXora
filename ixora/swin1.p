/* swin1.p
 * MODULE
        Платежная система
 * DESCRIPTION

 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        18.06.2004 dpuchkov
 * CHANGES
        08.07.04 dpuchkov - добавил банк получ в заголовок свифта
        09.09.04 dpuchkov - убрал поле 57 из 103
        09.11.04 dpuchkov - добавил поле 57 в 103
        07.04.05 dpuchkov - перекомпиляция
        03.10.2011 aigul - перекомпиляция
        27.09.2012 evseev - логирование
*/







HIDE ALL.
def shared var s-remtrz like remtrz.remtrz.
def shared var v-refernumber as char.
def shared var v-swinbankb like swbody.content[1].
def shared var v-swinbankb2 like swbody.content[2].
def shared var v-destnumber as char.
def shared var v-dest202 as char.


def shared var val_103_54con1 like swbody.content[1].
def shared var val_103_54con2 like swbody.content[2].
def shared var val_103_54con3 like swbody.content[3].
def shared var val_103_54con4 like swbody.content[4].
def shared var val_103_54con5 like swbody.content[5].
def shared var val_103_54con6 like swbody.content[6].
def shared var val_103_type like swbody.type.


def var destination as char format "x(12)". /* real bic code    */
def var destdescr as char format "x(12)". /* description of the real bic code    */
def var i        as integer.
def var tmps     as char format "x(1)".
def var pos53    as integer.
def var tmptitle as char.
def var tmpstr   as char.
def var result   as log.
def var mesg     as char.
def var err      as char.
def var ourbank  as char.
def var ourcode as integer.
def var country  as char init ?.
def var logic as logical init true.
def var tmpcontent like swbody.content[1].

/** Параметры для ввода **/
define input parameter swmt as char format "x(3)". /*init '100'.   */
define var scif like cif.cif.                      /*init 'T24198'.*/
def var vdate1 as char format "x(23)" init  "Value Date 1 " .
run savelog("swiftmaket", "swin1.p 70. " + string(s-remtrz) + " " + swmt).
{comm-txb.i}
{swm-tst.i}
{swmt-den.i}
{get-dep.i}
{global.i}

find remtrz where remtrz.remtrz = s-remtrz.
find first cmp no-lock.
find crc where crc.crc = remtrz.tcrc no-lock.
vdate1 = vdate1 + string(remtrz.valdt1, "99/99/99").

find first swlist where swlist.mt = swmt no-lock no-error.
pos53 = LOOKUP("53", swlist.flist). /* Позиция курсора в брaузе, по умолчанию */
                                    /* Название макета/загoловок фрейма       */

/* Название макета, BIC наименование/загoловок фрейма и поля DS   */
find first bankl where bankl.bank = remtrz.rbank no-lock no-error.
if avail bankl then do:
    destination = caps(trim(substr(bankl.bic, 3, 12))).
    run swiftext2(INPUT destination, INPUT-OUTPUT result, INPUT-OUTPUT destdescr).
    if swlist.descr = "MT103" then do:
       tmptitle = swlist.descr + ", Destination: " + v-destnumber + " " + substr(destdescr,1,50).
    end. else do:
       tmptitle = swlist.descr + ", Destination: " + destination + " " + substr(destdescr,1,50).
       v-dest202 = destination.
    end.
end.

ourbank=comm-txb().
ourcode=comm-cod().

/* Временная таблица для ввода свифтового макета */
def new shared temp-table swin like swbody
     field mandatory as char format "x(2)"
     field descr     as char format "x(30)"
     field feature   as char format "x(12)"
     field length    like swfield.length
     index ind is primary swfield type .   /* Размер поля             */

{swmtswin.i} /* */
{swmt-cnt.i} /* Фрейм для ввода значения поля */
{swmt.i}     /* Процедуры                     */
/*****************************************************************************************************/
 if remtrz.ord = ? then
 do:
   run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "swin1.p 120", "1", "", "").
 end.
 /*****************************************************************************************************/
{swmt1.i}
/*****************************************************************************************************/
 if remtrz.ord = ? then
 do:
   run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "swin1.p 127", "1", "", "").
 end.
 /*****************************************************************************************************/

DEFINE QUERY q1 FOR swin.
DEFINE BUTTON btSV LABEL "Отправить".
DEFINE BUTTON btVI LABEL "Просмотр".
DEFINE BUTTON btCL LABEL "Отмена".
DEFINE BUTTON btSN LABEL "Отправка".


if swlist.descr = "MT103" then do:
  find first swin where swin.rmz = s-remtrz and swin.swfield = "54" no-error.
  if avail swin then do:
        swin.content[1] = val_103_54con1.
        swin.content[2] = val_103_54con2.
        swin.content[3] = val_103_54con3.
        swin.content[4] = val_103_54con4.
        swin.content[5] = val_103_54con5.
        swin.content[6] = val_103_54con6.
        run savelog("swiftmaket", "swin1.p 143. " + string(swin.rmz)).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.swfield)).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[1])).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[2])).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[3])).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[4])).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[5])).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[6])).
  end. else do:
     create swin.
     update
        swin.rmz = s-remtrz
        swin.type = val_103_type
        swin.swfield = "54"
        swin.content[1] = val_103_54con1
        swin.content[2] = val_103_54con2
        swin.content[3] = val_103_54con3
        swin.content[4] = val_103_54con4
        swin.content[5] = val_103_54con5
        swin.content[6] = val_103_54con6 .
        run savelog("swiftmaket", "swin1.p 163. " + string(swin.rmz)).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.swfield)).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[1])).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[2])).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[3])).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[4])).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[5])).
        run savelog("swiftmaket", "swin1.p    . " + string(swin.content[6])).

  end.

  find first swin where swin.rmz = s-remtrz and swin.swfield = "53" no-error.
  if avail swin then do:
        swin.type = "A".
        swin.content[1] = "/" + v-dest202.
     run savelog("swiftmaket", "swin1.p 178. " + string(swin.rmz)).
     run savelog("swiftmaket", "swin1.p    . " + string(swin.swfield)).
     run savelog("swiftmaket", "swin1.p    . " + string(swin.content[1])).
  end. else do:
     create swin.
     update
        swin.rmz = s-remtrz
        swin.type = "A"
        swin.swfield = "53"
        swin.content[1] = "/" + v-dest202.
     run savelog("swiftmaket", "swin1.p 188. " + string(swin.rmz)).
     run savelog("swiftmaket", "swin1.p    . " + string(swin.swfield)).
     run savelog("swiftmaket", "swin1.p    . " + string(swin.content[1])).
  end.


end.

def browse b1
    query q1
    disp swin.mandatory  format "x(1)"  no-label
         swin.swfield    format "x(2)"  no-label
         swin.type       format "x(1)"  no-label
         swin.content[1] format "x(35)" no-label
         swin.content[2] format "x(35)" no-label
         swin.content[3] format "x(35)" no-label
         swin.content[4] format "x(35)" no-label
         swin.content[5] format "x(35)" no-label
         swin.content[6] format "x(35)" no-label
         with size 80 by 15 title tmptitle
         SEPARATORS NO-ASSIGN.


DEF Frame f1
    b1 at x 1 y 1
    btSV at x 24  y 112
    btCL at x 120 y 112
    with scrollable no-box.

ON CTRL-A ANYWHERE DO:
 run savelog("swiftmaket", "swin1.p 218. ").
 run swmt-arc.
end.

ON value-changed of b1 IN FRAME f1 DO:
 run savelog("swiftmaket", "swin1.p 223. ").
 RUN dspl-row.
end.

ON return of b1 IN FRAME f1 DO:
 run savelog("swiftmaket", "swin1.p 228. ").
 RUN updt-row.
 browse b1:refresh().
 APPLY "GO" TO swin.type IN FRAME ord-info.
end.

on help of b1 in frame f1 do:
 run savelog("swiftmaket", "swin1.p 235. ").
 run help-row.
end.

ON CHOOSE OF btSV IN FRAME f1 do:
  run savelog("swiftmaket", "swin1.p 240. ").
  if swmt = "202" then do:
    run save-row1.
  end. else
    run save-row.
  if return-value = "ok" then do:
     APPLY "WINDOW-CLOSE" TO BROWSE b1.
  end.
END.

ON CHOOSE OF btCL IN FRAME f1 do:
 APPLY "WINDOW-CLOSE" TO BROWSE b1.
END.

OPEN QUERY q1 FOR EACH swin by swin.swfield.



APPLY "VALUE-CHANGED" TO BROWSE b1.
ENABLE ALL WITH FRAME f1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.


find first swin where swin.rmz = s-remtrz and swin.swfield = "20" no-lock no-error.
if avail swin and swlist.descr = "MT202" then do:
  v-refernumber = swin.content[1].
end.

find first swin where swin.rmz = s-remtrz and swin.swfield = "58" no-lock no-error.
if avail swin and swlist.descr = "MT202" then do:
  run savelog("swiftmaket", "swin1.p 270. " + string(swin.rmz)).
  run savelog("swiftmaket", "swin1.p    . " + string(swin.swfield)).
  run savelog("swiftmaket", "swin1.p    . " + string(swin.content[1])).
  run savelog("swiftmaket", "swin1.p    . " + string(swin.content[2])).
  v-destnumber =  caps(trim(substr(swin.content[2], 1, 12))).
  v-swinbankb = swin.content[1].
  v-swinbankb2 = swin.content[2].
end.


find first swin where swin.rmz = s-remtrz and swin.swfield = "57" no-lock no-error.
if avail swin and swlist.descr = "MT202" then do:
   run savelog("swiftmaket", "swin1.p 282. " + string(swin.rmz)).
   run savelog("swiftmaket", "swin1.p    . " + string(swin.swfield)).
   run savelog("swiftmaket", "swin1.p    . " + string(swin.content[1])).
   run savelog("swiftmaket", "swin1.p    . " + string(swin.content[2])).
   run savelog("swiftmaket", "swin1.p    . " + string(swin.content[3])).
   run savelog("swiftmaket", "swin1.p    . " + string(swin.content[4])).
   run savelog("swiftmaket", "swin1.p    . " + string(swin.content[5])).
   run savelog("swiftmaket", "swin1.p    . " + string(swin.content[6])).
   val_103_54con1 = swin.content[1].
   val_103_54con2 = swin.content[2].
   val_103_54con3 = swin.content[3].
   val_103_54con4 = swin.content[4].
   val_103_54con5 = swin.content[5].
   val_103_54con6 = swin.content[6].
   val_103_type = swin.type .
end.














