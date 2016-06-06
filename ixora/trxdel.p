/* trxdel.p
 * MODULE
        Генератор транзакций
 * DESCRIPTION
        Удаление проводок
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
        22.07.2002 sasco - возврат сумм по АРП счетам из arpcon
        26/09/2002 sasco - удаление проводок по дебиторам
        21/09/2003 sasco - удаление записей из mobtemp (KCell, KMobile, Пласт. карточки)
        16/03/2004 nataly - удаление записей из aad ( доп взносы по депозитам)
        15.04.2004 nadejda - do transaction и сообщения переведены на русский
        13/05/2004 madiyar - добавил второй входной пар-р showres - показывать запрос причины удаления транзакции в jlcopy или нет.
                             Параметр передается в jlcopy.
        18/11/2004 u00121 - проверка наличия дочерней rmz на филиалах, и если платеж уже там зарегистрирован и создана первая проводка,
                            не дает удалять родительский платеж
        22.01.2005 nataly - вставила проверку на удаление транзакций Деп-та Пл Карт
        24.03.2005 saltanat - Включила выбор причины удаления из справочника и удалять проводку только после акцепта контролера
        17.05.2005 u00121 - изменен алгоритм от 18/11/2004 u00121, если это проводка платежной системы и найден RMZ, тока тогда обрабатываем поиск соответсвующего платежа в филиалах
        23.05.2005 u00121 - добавил, чтобы проверка работала только на платежи наших филиалов
        10.05.2006 u00124 - при удалении проводок по счетам сейфовых ячеек чистим данные таблицы depo.
        05/06/06 marinav - перекомпиляция
        07.08.2006 tsoy - запрет удаления проводок
        22/11/2010 galina - выгрузка удаленных операций в AML
        23/11/2010 madiyar - перекомпиляция
        23/09/2011 Luiza   - для errlist[51] = "Данная проводка находится у контр.лица для акцепта удаления проводки в п.м. 2.4.1.4.!".
                             изменила текст.
        27/09/2011 Luiza   - для errlist[50] = "Необходим акцепт удаления контроллирующего лица в п.м. 2.4.1.4.!".
                             изменила текст
        08.05.2012 k.gitalov запрет на удаление проводок по ЭК
        12.12.2012 Luiza выводить message запрет на удаление проводок по ЭК
        23/07/2013 Luiza  - ТЗ 1935 если в PCPAY статус 'send' транзакцию удалять нельзя
*/

def input parameter vjh as inte.
def input parameter showreas as logi.
def output parameter rcode as inte.
def output parameter rdes as char.

def shared var g-ofc as char.
def shared var g-today as date.

def var res as log. /*u00121 18/11/2004 для проверки дочернего платежа на филиале*/

def var vcrc as inte.
def var vdam as deci.
def var vcam as deci.
def buffer fcrc for crc.
def buffer tcrc for crc.

def var v-arp as char. /*nataly 20/01/05 для проверки  счетов Деп-та Пласт Карт*/
def var v-ourbnk as char.
def var vv-joudoc as char.
def var vv-remtrz as char.

/*def new shared var g-today as date.
def new shared var g-ofc as char.
find last cls no-lock.
g-today = cls.cls + 1.
g-ofc = userid('bank').*/

def new shared var s-jh like jh.jh.
s-jh = vjh.
def new shared var s-aah as int.
def new shared var s-line as int.
def new shared var s-force as log initial false.
def var errlist as char extent 60.
errlist[24] = "Транзакция не найдена! Удаление невозможно!".
errlist[25] = "Статус транзакции > 0! Удаление невозможно!".
errlist[26] = "Транзакция принадлежит другому офицеру! Недопустимый запрос на удаление!".
errlist[27] = "Транзакция уже отштампована! Удаление невозможно!".
errlist[28] = "Для удаления проводки необходим контроль Деп-та Пл Карт! ".
errlist[50] = "Необходим акцепт удаления контроллирующего лица в п.м. 2.4.1.4.! ". /* 24.03.05 saltanat */
errlist[51] = "Данная проводка находится у контр.лица для акцепта удаления проводки в п.м. 2.4.1.4.!".
errlist[52] = "По данному департаменту не заведен контроллирующий! ".
errlist[53] = "Данная проводка не удаляется! ".
errlist[54] = "Отмена удаления! ".
errlist[55] = "Запрет на удаление проводок c АРП КАРТЕЛ !!! ".

define variable ret as logical init false.
define variable i as integer init 0.
define variable v-rec  as char init ''.
define variable v-send as char init ''.
define variable v-tem  as char init ''.
define variable v-mess as char init ''.


/* запрет удаления проводок */
for each jl where jl.jh = vjh no-lock:
   if jl.acc = "011999832" then do:
      message "Запрет на удаление проводок c АРП КАРТЕЛ !!! " view-as alert-box.
      rcode = 55.
      rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
      return.
   end.
end.

 find first sm18data where sm18data.jh = vjh and ( sm18data.state = 1 or sm18data.state = 0 ) no-lock no-error.
 if avail sm18data then do:
  message "Запрет на удаление проводок ЭК !!! " view-as alert-box.
  rcode = 53.
  rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
  return.
 end.

/* проверка статуса в pcpay */
vv-joudoc = "".
vv-remtrz = "".
find first joudoc where joudoc.jh = vjh and joudoc.rescha[4] ne '' no-lock no-error.
if available joudoc then do:
    vv-joudoc = joudoc.docnum.
    find first pcpay where pcpay.jou  = joudoc.docnum no-lock no-error.
    if available pcpay and pcpay.sts = "send" then do:
        message "Транзакция не может быть удалена. Файл OW сформирован. Обратитесь в Департамент платежных карточек!" view-as alert-box error.
        rcode = 54.
        rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
        return.
    end.
    if available pcpay and pcpay.sts <> "send" then do:
        find first remtrz where remtrz.remtrz = pcpay.ref no-lock no-error.
        if available remtrz then do:
            message "Был создан RMZ документ. Необходимо удалить " + pcpay.ref + " документ!" view-as alert-box error.
            rcode = 54.
            rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
            return.
        end.
    end.
end.
find first remtrz where remtrz.jh1 = vjh  no-lock no-error.
if available remtrz then do:
    vv-remtrz = remtrz.remtrz.
    find first pcpay where pcpay.ref  = remtrz.remtrz no-lock no-error.
    if available pcpay and pcpay.sts = "send" then do:
        message "Транзакция не может быть удалена. Файл OW сформирован. Обратитесь в Департамент платежных карточек!" view-as alert-box error.
        rcode = 54.
        rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
        return.
    end.
end.

do transaction on error undo, return:

  find jh where jh.jh = vjh exclusive-lock no-error.
  if not available jh then do:
     rcode = 24.
     rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
     return.
  end.
  find first jl where jl.jh = vjh and jl.sts > 0 no-lock no-error.
  if available jl then do:
     rcode = 25.
     rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
     return.
  end.
  /*
  if g-ofc <> "root" and g-ofc <> jh.who then do:
     rcode = 26.
     rdes = errlist[rcode] + ": " + string(vjh,"zzzzzzz9") + ": " + jh.who.
     return.
  end. */
  if jh.post = true then do:
     rcode = 27.
     rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
     return.
  end.
/*
  /*u00121 18/11/2004************************/
        find first remtrz where remtrz.remtrz = jh.party  no-lock no-error. /*u00121 17/05/2005 если это проводка платежной системы и найден RMZ, тока тогда обрабатываем поиск соответсвующего платежа в филиалах*/
        if avail remtrz and remtrz.sbank begins "TXB" then /*u00121 23.05.2005 добавил, чтобы проверка работала только на платежи наших филиалов*/
        do:
                run findrmz-br(vjh, output res). /*u00121 18/11/2004*/
                if res then  do:
                        rcode = 24.
                        rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
                        return.
                end. /*u00121 18/11/2004*/
        end. /*u00121 17/05/2005*/
  /*************************u00121 18/11/2004*/
*/
  /*nataly - cards control*/
   /* берем счета из справочника*/
 for each jl where jl.jh = vjh no-lock:
      if jl.dc <> 'C' then next.

   find sysc where sysc.sysc = "cardac" no-lock no-error.
   if avail sysc then v-arp = sysc.chval.

   if lookup(trim(jl.acc), trim(v-arp)) <> 0  then do: /*если проводка идет по счету Деп-та Пласт Карт*/
   find cursts where cursts.sub = 'trx' and cursts.acc = string(jl.jh) no-lock no-error.
    if not  avail cursts  or cursts.sts <> 'con' then do:
      message 'Для удаления транзакции необходим контроль Деп-та Пл. Карт'
      view-as alert-box.
      rcode = 28.
      rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
     return.
    end.
   end.
  end.

/* ------- 18.03.05 saltanat - Проверка и запрос акцепта удаления транзакции ------- */
  if showreas then do:
    find first trxdel_aks_control where trxdel_aks_control.jh = vjh no-lock no-error.
    if not avail trxdel_aks_control then do:
       /* Отправляем на контроль */
       run dreason(vjh,  output rcode, output rdes).
       if rcode = 0 then do:
          rcode = 50.
          rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
       end.
       else if rcode = -1 then do:
           rcode = 54.
           rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
       end.
       return.
    end.
    else do:
       /* Если удаление на контроле */
       if trxdel_aks_control.sts = 'd' then do:
          rcode = 51.
          rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
          return.
       end.

       /* Если контроллер запретил удаление */
       if trxdel_aks_control.sts = 'r' then do:
          ret = false.
          message "Запрещено удалять проводку. Повторить запрос на удаление?" view-as  alert-box question buttons yes-no update ret.
          if ret then do:
             /* Отправляем на контроль */
             run dreason(vjh,  output rcode, output rdes).
             if rcode = 0 then do:
                rcode = 50.
                rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
             end.
             else if rcode = -1 then do:
                rcode = 54.
                rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
             end.
             return.
          end.
          else do:
              rcode = 53.
              rdes = errlist[rcode] + ": " +  string(vjh,"zzzzzzz9").
              return.
          end.
       end.
   end.
  end. /* showreas */
/* ------- 18.03.05 saltanat - Проверка и запрос акцепта удаления транзакции ------- */


  /* sasco - debetors */
  {trx-debdel.i}

  /* sasco - mobile & pl.cards */
  {trx-mobdel.i}

  run jlcopy(false). /* 24.03.05 saltanat - input parameter was showreas */

  find sysc where sysc.sysc = "ourbnk" no-lock no-error.
  if avail sysc then v-ourbnk = sysc.chval.
  for each jl of jh exclusive-lock:

   /* by sasco -> change arpcon table record for controlled ARP`s from jl.DRacc */
    if jl.dc = "D" then
    for each arpcon where arpcon.arp = jl.acc and
                          arpcon.txb = sysc.chval exclusive-lock:
        /* если нет в списке пользователей и надо было контролировать... */
        if LOOKUP (jl.who, arpcon.uids) = 0 and arpcon.checktrx then
                  arpcon.curr = arpcon.curr - jl.dam.
    end.

    /*nataly - доп взносы по депозитам*/
    if jl.dc = "C" then do:
     find first aad where aad.aaa = jl.acc and aad.regdt = jl.jdt and aad.cam = jl.cam and aad.gl = jl.gl no-error.
     if avail aad then delete aad.
    end.

    /*u00124 - реквизиты ячеек*/
    if jl.dc = "C" then do:
     find first depo where depo.aaa = jl.acc and substr(depo.prlngperiod,1,8) = string(jl.jdt) and depo.sum = jl.cam  no-error.
     if avail depo then delete depo.
    end.


    {trxupd-f.i -}
  /*
   if jl.subled = "OCK" then do:
   /*
   If no more non zero turnovers on any level then delete OCK subled*/
     find first trxbal where trxbal.subled = jl.subled
                       and trxbal.acc = jl.acc
                       and (trxbal.dam > 0 or trxbal.cam > 0) no-lock no-error.
      if not available trxbal then do:
         for each trxbal where trxbal.subled = jl.subled
                         and trxbal.acc = jl.acc exclusive-lock:
             delete trxbal.
         end.
         find ock where ock.ock = jl.acc exclusive-lock no-error.
         if available ock then delete ock.
      end.
   /*End of OCK subled deletion*/
   end. /*if ock*/
  */

   /*This piece is until "short" trancsactions remains*/
/*
      if jl.aah gt 0 then do:
         find aah where aah.aah eq jl.aah exclusive-lock.
         for each aal of aah exclusive-lock:
             delete aal.
         end.
         delete aah.
      end.
*/
   /*End of piece*/
      if jl.deal <> "" then do:
         find fexp where fexp.fex = jl.deal exclusive-lock no-error.
         if available fexp then delete fexp.
      end.
      for each trxcods where trxcods.trxh = jl.jh exclusive-lock:
          delete trxcods.
      end.
      delete jl.
  end.
  jh.party = jh.party + " deleted" .

  /* удаляем запись в pcpay */
  if vv-joudoc <> "" then do:
      find first pcpay where pcpay.jou  = vv-joudoc and trim(pcpay.jou) <> "" and pcpay.sts <> "send" exclusive-lock no-error.
      if available pcpay and trim(pcpay.jou) <> "" and pcpay.sts <> "send" then delete pcpay.
      find first pcpay no-lock no-error.
  end.
  if vv-remtrz <> "" then do:
      find first pcpay where pcpay.ref  = vv-remtrz and trim(pcpay.ref) <> "" and pcpay.sts <> "send" exclusive-lock no-error.
      if available pcpay and trim(pcpay.ref) <> "" and pcpay.sts <> "send" then delete pcpay.
      find first pcpay no-lock no-error.
  end.
end.  /* do transaction */

/******galina - для выгрузки в АМЛ********/
def var v-docnum as char.
v-docnum = ''.
if (jh.party begins 'jou') or (jh.party begins 'RMZ') or (jh.party begins 'MXP') or (jh.party = '') then do:
    if jh.party begins 'jou' or jh.party begins 'RMZ' then do:
        v-docnum = entry(1,jh.party,' ').
        if v-docnum <> '' then do:
            find first amloffline where amloffline.bank = v-ourbnk and amloffline.operCode = v-docnum and amloffline.sts <> "del" no-lock no-error.
            if avail amloffline then do transaction:
                find current amloffline exclusive-lock no-error.
                amloffline.issueDBID = -1.
                amloffline.sts = 'predel'.
                find current amloffline no-lock no-error.
            end.
        end.
    end.
    if (jh.party begins 'MXP') or (jh.party = '') then do:
        find nmbr where nmbr.code = "translat" no-lock no-error.
        if avail nmbr then do:
            for each translat where translat.jh = jh.jh no-lock:
                if substr(translat.nomer,1,4) <> nmbr.pref then next.
                find first amloffline where amloffline.bank = v-ourbnk and amloffline.operCode = translat.nomer and amloffline.sts <> "del" no-lock no-error.
                if avail amloffline then do transaction:
                    find current amloffline exclusive-lock no-error.
                    amloffline.issueDBID = -1.
                    amloffline.sts = 'predel'.
                    find current amloffline no-lock no-error.
                end.
            end.
            for each r-translat where r-translat.jh = jh.jh no-lock:
                if r-translat.rec-code <> nmbr.pref then next.
                find first amloffline where amloffline.bank = v-ourbnk and amloffline.operCode = r-translat.nomer and amloffline.sts <> "del" no-lock no-error.
                if avail amloffline then do transaction:
                    find current amloffline exclusive-lock no-error.
                    amloffline.issueDBID = -1.
                    amloffline.sts = 'predel'.
                    find current amloffline no-lock no-error.
                end.
            end.

        end.
    end.
end.

/************/

{trxupd-i.i}

