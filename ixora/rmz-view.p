/* rmz-view.p
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        16.11.09 marinav формат 20-го поля
*/

 def shared var s-remtrz like remtrz.remtrz.
 def var acode like crc.code.
 def var bcode like crc.code.
 def var t-pay like remtrz.amt.
 def buffer tgl for gl.
 def var ord1 as char.
 def var ord2 as char.

 find first remtrz where remtrz.remtrz = s-remtrz no-lock .
 {rmz.f}
 find gl where gl.gl = remtrz.drgl no-lock no-error.
 find tgl where tgl.gl = remtrz.crgl no-lock no-error.
 find crc where crc.crc = remtrz.fcrc no-lock no-error .
  if avail crc then acode = crc.code .
 find crc where crc.crc = remtrz.tcrc no-lock no-error .
  if avail crc then bcode = crc.code .
 t-pay = remtrz.margb + remtrz.margs .
 find first ptyp where ptyp.ptype = remtrz.ptype no-lock no-error.
 if avail ptyp then display ptyp.des with frame remtrz.

  find first tarif2 where trim(tarif2.num) + trim(tarif2.kod) = string(remtrz.svccgr) and tarif2.stat = 'r' no-lock no-error .
  if avail tarif2 then pakal = tarif2.pakalp .
  else pakal = ' ' .


def var prilist as cha.
find sysc where sysc.sysc = 'PRI_PS' no-lock no-error .
if not avail sysc or sysc.chval = '' then do:
 display 'Отсутствует запись PRI_PS в таблице SYSC!'.
 pause .
 undo .
 return .
end.
prilist = sysc.chval.

find first que where que.remtrz = remtrz.remtrz no-lock no-error .
if avail que then
   v-priory = entry(3 - int(que.pri / 10000 - 0.5 ) ,prilist).
   else
   v-priory = entry(1,prilist) .

 v-psbank = remtrz.sbank.
 if index(remtrz.rcvinfo[1],"/TAX/") <> 0 then do :
  v-kind = "Налог" .
 end .
 else
  if index(remtrz.rcvinfo[1],"/PSJ/") <> 0 then
  v-kind = "Пенсия" .
 else 
  v-kind = "Норм." .
 ord1 = substring(remtrz.ord,1,70).  /* разбивка поля отправителя на две части чтобы было видно */
 ord2 = substring(remtrz.ord,71,70). /* реквизиты отправителя */
 display
     remtrz.remtrz
     remtrz.sqn  remtrz.rdt
     remtrz.valdt1   remtrz.valdt2
     remtrz.jh1      remtrz.jh2
     v-psbank remtrz.rbank
     remtrz.scbank remtrz.rcbank
     remtrz.saddr remtrz.raddr
     remtrz.sacc remtrz.racc rsub
     remtrz.drgl
     remtrz.crgl
     remtrz.dracc  remtrz.cracc
     remtrz.fcrc acode remtrz.tcrc bcode
     remtrz.amt      remtrz.payment
     remtrz.ptype  remtrz.cover
     remtrz.svca remtrz.svcrc remtrz.svcaaa remtrz.svccgl
     remtrz.svccgr pakal
     /*
     remtrz.margb remtrz.margs t-pay
     */
     remtrz.bb
     remtrz.ba
     remtrz.bn
/*   remtrz.ord*/
     ord1
     ord2
     remtrz.bi
     v-priory v-kind
     with frame remtrz .
     if avail tgl then  display tgl.sub with frame remtrz .
     if avail gl then  display gl.sub with frame remtrz .

     display skip "Трансп Nr :" remtrz.t_sqn no-label skip
     remtrz.sqn label "Nr." format "x(70)" skip
     remtrz.ref label "Ссыл N" format "x(70)" skip
     remtrz.ordins label "Банк отпр."   skip
     substr(remtrz.intmed,1,70) label "Б.Пос." format "x(70)" skip
     substr(remtrz.intmed,71,70) label "Б.Пос." format "x(70)" skip
     remtrz.intmedact label "Сч.Пос" format "x(70)"          skip
     remtrz.detpay label "Детали"
     remtrz.rcvinfo label "М/Б Инфо"
     with side-label
      no-box . pause 0 .
