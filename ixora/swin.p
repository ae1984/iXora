/* swin.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Ввод свифтовых макетов
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK
 * AUTHOR
        01.06.2002 koval
 * CHANGES
        11.08.2003 sasco Запуск REFRESH формы после редактирования поля
        05.08.2011 aigul - recompile
        07.11.2011 aigul - recompile
        23.11.2011 aigul - recompile
        31.01.2012 aigul - заполнение МТ 103 для ИБ
        16.02.2012 aigul - recompile
        27.09.2012 evseev - логирование
        02.09.2013 evseev - tz-926
        05.11.2013

*/

HIDE ALL.

def shared var s-remtrz like remtrz.remtrz.
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


/** Параметры для ввода **/
define input parameter swmt as char format "x(3)". /*init '100'.   */


run savelog("swiftmaket", "swin.p 53. " + string(s-remtrz) + " " + swmt).

define var scif like cif.cif.                      /*init 'T24198'.*/
def var vdate1 as char format "x(23)" init  "Value Date 1 " .

{comm-txb.i}
{swm-tst.i} /*x*/
{swmt-den.i} /*x*/
{get-dep.i}
{global.i}

find remtrz where remtrz.remtrz = s-remtrz exclusive-lock.
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
   result = true.
   run swfind(INPUT destination, INPUT-OUTPUT result, INPUT-OUTPUT destdescr).
   if result then do:
      tmptitle = swlist.descr + ", Destination: " + destination + " " + substr(destdescr,71,35).
   end. else tmptitle = swlist.descr + ", Destination: " + destination.
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
 if remtrz.ord = ? then do:
   run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "swin.p 102", "1", "", "").
 end.
 /*****************************************************************************************************/


DEFINE QUERY q1 FOR swin.
DEFINE BUTTON btSV LABEL "Отправить".
DEFINE BUTTON btVI LABEL "Просмотр".
DEFINE BUTTON btCL LABEL "Отмена".
DEFINE BUTTON btSN LABEL "Отправка".

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
   run savelog("swiftmaket", "swin.p 134. ").
   run swmt-arc.
end.

ON value-changed of b1 IN FRAME f1 DO:
   run savelog("swiftmaket", "swin.p 139. ").
   RUN dspl-row.
end.

ON return of b1 IN FRAME f1 DO:
   run savelog("swiftmaket", "swin.p 144. ").
   RUN updt-row.
   browse b1:refresh().
   APPLY "GO" TO swin.type IN FRAME ord-info.
end.

on help of b1 in frame f1 do:
   run savelog("swiftmaket", "swin.p 151. ").
   run help-row.
end.

ON CHOOSE OF btSV IN FRAME f1 do:
   run savelog("swiftmaket", "swin.p 156. ").
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


