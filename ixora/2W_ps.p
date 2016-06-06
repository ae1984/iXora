/* 2W_ps.p
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
        06.11.2003 nadejda - добавила проверку средств на ARP-счете
        27.08.2005 dpuchkov - добавил проверку на инкассовые специнструкции.
        14.09.2005 dpuchkov - добавил возможность проплаты пенсионных если есть ограничение за исключением платежей в бюджет
                              в связи с изменением в законодательстве.
        26.09.2005 dpuchkov - добавил возможность проплаты социальных если есть ограничение в п 1.6.2.9 (Т.З.ї131)
        05.07.2011 Luiza   -  При пополнении счета с другого филиала комиссия не снимается со счета до тех пор,
                              пока не поступит сумма пополнения (пока платеж пополнения счета не приобретет очередь обработанного документа "F")
        28.03.2012 aigul - увеличила время для клиринга до 2.45

*/


{global.i}
{lgps.i }

function Chk-ibal returns logical.
def var vbal as decimal.
def buffer xaaa for aaa.

   find first gl where gl.gl = remtrz.drgl no-lock no-error.

   case gl.sub:
     when "cif" then do:
       /* проверка суммы на клиентском счете */

       find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
       if not avail aaa then do:
          v-text = "Ошибка! " + remtrz.dracc + " не найден...".
          run lgps.
          return false.
       end.

       if aaa.craccnt <> "" then
       find first xaaa where xaaa.aaa = aaa.craccnt exclusive-lock no-error.
       vbal = aaa.cbal - aaa.hbal + ( if available xaaa then xaaa.cbal else 0 ).

/* если есть ограничение кроме пенсионных то пропускаем */
  def buffer b1-aas for aas.
  def var d_sm as decimal. d_sm = 0.
  find last b1-aas where b1-aas.aaa = aaa.aaa and b1-aas.sta = 2 no-lock no-error.
  if not avail b1-aas then do:
         find last b1-aas where b1-aas.aaa = aaa.aaa and b1-aas.sta = 11 no-lock no-error.
         if avail b1-aas then do:
            find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
            if avail sub-cod and lookup(substr(sub-cod.rcode, 7, 3), "010,019,012,017") <> 0 /*and substr (remtrz.rcvinfo[1], 2, 3) = "PSJ" */ then do:
               d_sm = 0.
               for each b1-aas where b1-aas.aaa = aaa.aaa and b1-aas.sta = 11 no-lock:
                   d_sm = d_sm + b1-aas.chkamt.
               end.
               vbal = vbal + d_sm.
             end.
         end.
         d_sm = 0.
         find last b1-aas where b1-aas.aaa = aaa.aaa and b1-aas.sta = 16 no-lock no-error.
         if avail b1-aas then do:
            find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
            if avail sub-cod and lookup(substr(sub-cod.rcode, 7, 3), "010,019,012,017") <> 0 /*and substr (remtrz.rcvinfo[1], 2, 3) = "PSJ" */ then do:
               d_sm = 0.
               for each b1-aas where b1-aas.aaa = aaa.aaa and b1-aas.sta = 16 no-lock:
                  d_sm = d_sm + b1-aas.chkamt.
               end.
               vbal = vbal + d_sm.
            end.
         end.

         d_sm = 0.
         find last b1-aas where b1-aas.aaa = aaa.aaa and lookup(string(b1-aas.sta), "11,16") <> 0 no-lock no-error.
         if avail b1-aas then do:
            find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = "rmz" and sub-cod.d-cod = "eknp" use-index dcod no-lock no-error.
            if avail sub-cod and lookup(substr(sub-cod.rcode, 7, 3), "010,019,012,017") <> 0 /*and substr (remtrz.rcvinfo[1], 2, 3) = "PSJ" */ then do:
               d_sm = 0.
               for each b1-aas where b1-aas.aaa = aaa.aaa and lookup(string(b1-aas.sta), "4,5,6,8") <> 0 no-lock:
                   d_sm = d_sm + b1-aas.chkamt.
               end.
               vbal = vbal + d_sm.
            end.
         end.
  end.

/* если есть ограничение кроме пенсионных то пропускаем */


     end.

     when "arp" then do:
       /* проверка суммы на ARP-счете */
       find first arp where arp.arp = remtrz.dracc no-lock no-error.
       if not avail arp then do:
          v-text = "Ошибка! " + remtrz.dracc + " не найден...".
          run lgps.
          return false.
       end.

       find trxbal where trxbal.sub = gl.sub and trxbal.acc = remtrz.dracc and
                         trxbal.crc = arp.crc and trxbal.lev = 1 no-lock no-error.
       vbal = trxbal.cam - trxbal.dam.
       if lookup(gl.type, "a,r") > 0 then vbal = - vbal.
     end.

/* 06.11.2003 nadejda - этот кусок требует дополнительной тщательной проверки, пока не включаю
     when "ast" then do:
       / * проверка суммы на AST-счете * /
       find first ast where ast.ast = remtrz.dracc no-lock no-error.
       if not avail ast then do:
          v-text = "Ошибка! " + remtrz.dracc + " не найден...".
          run lgps.
          return false.
       end.

       find trxbal where trxbal.sub = gl.sub and trxbal.acc = remtrz.dracc and
                         trxbal.crc = ast.crc and trxbal.lev = 1 no-lock no-error.
       vbal = trxbal.cam - trxbal.dam.
       if lookup(gl.type, "a,r") > 0 then vbal = - vbal.
     end.

     otherwise
       / * в случае lon проверка должны быть ДО отправки RMZ, fun,dfb - проверка есть внутри 2T * /
       return true.
*/
   end case.

   vbal = vbal - (if remtrz.svcaaa = remtrz.dracc then remtrz.svca else 0) - remtrz.amt.

   if vbal < 0 then do:
/*
     v-text = "Ошибка! Нехватка средств " + remtrz.dracc + "  " + string(vbal, "->>>,>>>,>>>,>>>,>>9.99").
     run lgps.
*/
     return false.
   end.


   /* проверка суммы комиссии */
   if remtrz.svcaaa <> "" then do:
     find first aaa where aaa.aaa = remtrz.svcaaa no-lock no-error.
     if avail aaa then do:
       if aaa.craccnt <> "" then
       find first xaaa where xaaa.aaa = aaa.craccnt exclusive-lock no-error.
       vbal = aaa.cbal - aaa.hbal + (if available xaaa then xaaa.cbal else 0) - remtrz.svca.

       if vbal < 0 then return false.
     end.
     else do:
       find first arp where arp.arp = remtrz.svcaaa no-lock no-error.
       if avail arp then do:
         find trxbal where trxbal.sub = gl.sub and trxbal.acc = remtrz.svcaaa and
                           trxbal.crc = arp.crc and trxbal.lev = 1 no-lock no-error.
         vbal = trxbal.cam - trxbal.dam.
         find gl where gl.gl = arp.gl no-lock no-error.
         if lookup(gl.type, "a,r") > 0 then vbal = - vbal.

         if vbal < 0 then return false.
       end.
       else do:
         v-text = "Ошибка! Счет для снятия комиссии " + remtrz.svcaaa + " не найден...".
         run lgps.
         return false.
       end.
     end.
   end.

   return true.
end function.


def buffer xaaa   for aaa.
def var v-amt     like remtrz.payment.
def var v-crc     like remtrz.tcrc.
def var v-sqn     as cha .
def var v-field   as char.
def var num       as cha.
def var v-weekbeg as int.
def var v-weekend as int.

/* Luiza--------------------------------------------------------------*/
def buffer b-que for que.
def buffer b-remtrz for remtrz.

/*--------------------------------------------------------------------------*/

def var lbnstr like remtrz.cracc initial "yyyyyyyyyyyyy" .
find sysc where sysc.sysc = 'LBNSTR' no-lock  no-error.
if avail sysc then lbnstr = trim(sysc.chval) .
find sysc "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval. else v-weekend = 6.
find sysc "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval. else v-weekbeg = 2.

for each que where que.pid = m_pid and que.con = "W"
    use-index fprc exclusive-lock:

/* Luiza--------------------------------------------------------------*/
find first remtrz where remtrz.remtrz = que.remtrz no-lock no-error.
if not avail remtrz then next.
find first filpayment where filpayment.stscom = 'new1' and filpayment.whn = g-today and filpayment.bankfrom = remtrz.actinsact and trim(filpayment.rem[3]) = remtrz.remtrz no-lock no-error.
if avail filpayment and trim(filpayment.rem[2]) = '2' and trim(filpayment.rem[4]) <> "" then do:

    /* vv-rmz = "PU" + string(integer(truncate(vv-regno / 1000 , 0)),"9999")
    + "    " + trim(filpayment.rem[1]) + "-S" + trim(filpayment.bankfrom) +
    fill(" " , 12 - length(trim(filpayment.bankfrom))) +
    (trim(filpayment.arp) + fill(" " , 10 - length(trim(filpayment.arp)))) +
    substring(string(filpayment.whn),1,2) + substring(string(filpayment.whn),4,2) +
    substring(string(filpayment.whn),7,2).*/

    find first b-remtrz where b-remtrz.ref = filpayment.rem[4] no-lock no-error.
    if available b-remtrz then find first b-que where b-que.remtrz = b-remtrz.remtrz no-lock no-error.
    else next.
    if available b-que then if not (b-que.pid  = "F" and b-que.con = "W") then  next. /* если у платежа очередь не F, значит перевод еще не поступил, проводку комиссии не проводим, ждем.*/
    /* сохраним номер rmz для комиссии, чтобы в программе ELX_pz.p после пополнения счета арп
    создать проводку на счет дохода от комиссии согласно коду комиссии */
    find current filpayment exclusive-lock.
    filpayment.rem[5] = remtrz.ref.  /* номер rmz для комиссии  */
    filpayment.stscom = "sen1". /* статус суммы комиссии платеж в тенге отправлен  */
    find current filpayment no-lock.
    release filpayment.
end.

/*--------------------------------------------------------------------*/

    que.dw = today.
    que.tw = time.

    find first remtrz where remtrz.remtrz = que.remtrz no-lock no-error.

    if remtrz.info[8] <> "REINFORCED" then do:
        find first bankt where
        bankt.cbank = remtrz.sbank and
        bankt.crc = remtrz.tcrc and
        bankt.acc = remtrz.dracc no-lock no-error.
        if avail bankt then do:
            que.dp   = today.
            que.tp   = time.
            que.con  = "F".
            que.rcod = "2".
            v-text   = "Платеж " + remtrz.remtrz + " обработан. rcod=" + que.rcod.
            release que.
            run lgps.
            next.
        end.
    end.

    if not Chk-ibal() then do:
       release que.
       next.
    end.

    if remtrz.cracc = lbnstr
       and remtrz.cover ne 4 and remtrz.valdt2 < g-today then do:
       find current remtrz exclusive-lock.
       remtrz.valdt2 = g-today.
       /*
       repeat:
          find hol where hol.hol eq remtrz.valdt2 no-lock no-error.
          if not available hol and weekday(remtrz.valdt2) ge v-weekbeg
          and weekday(remtrz.valdt2) le v-weekend then leave.
          else remtrz.valdt2 = remtrz.valdt2 + 1.
       end.
       */
       v-text = remtrz.remtrz + " 2 дата валютирования изменена -> " +
       string( remtrz.valdt2 ).
       run lgps.
    end.

    if time > /*14.5 * 3600*/ 53100 and remtrz.cracc = lbnstr
    and remtrz.cover =  1 and remtrz.valdt2 = g-today then do:
        find current remtrz exclusive-lock.
        remtrz.cover = 2.
        v-text = remtrz.remtrz + " транспорт изменен 1 -> 2 ".
        run lgps.
    end.

    v-text   = "Платеж " + remtrz.remtrz + " отправлен с " + m_pid +
    " на 1 проводку.".
    que.dp   = today.
    que.tp   = time.
    que.con  = "F".
    que.rcod = "0".
    release que.
    run lgps.
end.

return.

