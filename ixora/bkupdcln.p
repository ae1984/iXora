/* bkupdcln.p
 * MODULE
        Пластиковые карточки
 * DESCRIPTION
        Изменение реквизитов клиента - формирование файла 
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
        12.01.06 marinav 
 * CHANGES
*/


{global.i}
{bknewcrd.i}
{get-dep.i}
{pk.i}
/*
s-pkankln = 40001.
s-credtype = '6'.
*/

def var s_bank as char no-undo.
def var v-dpt as integer no-undo.
def var v-adres as char extent 2 .
def var v-adresd as char extent 2 .

if s-pkankln = 0 then return.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause. 
  return.
end.
else s_bank = sysc.chval.

find pkanketa where pkanketa.bank = s_bank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if pkanketa.rescha[3] = '' then return. 

v-dpt = get-dep(g-ofc,g-today).

find first bkcard where bkcard.bank = s_bank and bkcard.nominal = integer(pkanketa.sumq) and bkcard.point = v-dpt 
           and bkcard.who1 <> '' and bkcard.who2 <> '' and bkcard.anketa = s-pkankln and  bkcard.contract_number = pkanketa.rescha[3] no-lock no-error.

if not avail bkcard then do:
  message skip " Карта в базе не найдена!" skip(1)
    view-as alert-box buttons ok .
  return.
end.

if bkcard.sta = 5 then do:
  message skip " Карта активизирована!" skip(1)
    view-as alert-box buttons ok .
  return.
end.


if pkanketa.sts  < "99" then do:
  message skip " Карта активизируется после подписания всех документов !" skip(1)
    view-as alert-box buttons ok .
  return.
end.

find first cmp no-lock no-error.

/* изменение реквизитов клиента */
      ClientMType = '2'.
      ContractMType = '0'.
      CardMType = '00'.
      RBScode = string(bkcard.rbs).
      ShortName = bkcard.client. 

      find pkanketh where pkanketh.bank = s_bank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and
       pkanketh.kritcod = "fname" no-lock no-error.
      if avail pkanketh then Name = trim(pkanketh.value1).

      find pkanketh where pkanketh.bank = s_bank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and
       pkanketh.kritcod = "lname" no-lock no-error.
      if avail pkanketh then Surname = trim(pkanketh.value1).

      find pkanketh where pkanketh.bank = s_bank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and
       pkanketh.kritcod = "mname" no-lock no-error.
      if avail pkanketh then  FatherName = trim(pkanketh.value1).

      find pkanketh where pkanketh.bank = s_bank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and
       pkanketh.kritcod = "bdt" no-lock no-error.
      if avail pkanketh then Birthday = date(trim(pkanketh.value1)).

      vrnn = pkanketa.rnn.
      PassType = 'ID'.

      find last card_status where card_status.rnn = vrnn no-lock no-error. 
      if avail card_status and card_status.pasport begins 'ID' then do:          
           if card_status.pasport begins 'ID-' 
               then PassType = 'ID1'.
               else PassType = 'ID' + string(inte(substring(card_status.pasport,3,1)) + 1).
      end. 

      Pass = pkanketa.docnum. 
      IsResident = yes.
      IsPrivate  = yes.
      IsCrc = '398'.
      CrLimit = 0.
      CrLimitSum = 0.
      SecName = 'security'.
      ContInfo = 'InsCardCon'.
      AccSch = "". 
      ServPack = "".
      ContractNum = ''.
      if avail cmp then City = entry(1,cmp.addr[1]).

      find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
          pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
      if avail pkanketh then HomePhone = trim(pkanketh.value1).
        
      run pkdefadres (pkanketa.ln, no, output v-adres[1], output v-adres[2], output v-adresd[1], output v-adresd[2]).
      BaseAddress[1] = replace (v-adres[1], "&nbsp;", " "). 
	 
      run Put_application.
  
      run Put_footer.
      run Copyfile.
   
/* активизация карты */
      ClientMType = '0'.
      ContractMType = '0'.
      CardMType = '30'.
      RBScode = string(bkcard.rbs).
      ShortName = bkcard.client.
      Name = ''.
      Surname = ''.
      FatherName = ''.
      Birthday = 01/01/01.
      PassType = ''.
      Pass = ''. 
      IsResident = yes.
      IsPrivate  = yes.
      IsCrc = ''.
      CrLimit = 0.
      CrLimitSum = 0.
      SecName = ''.
      AccSch = "". 
      ServPack = "".
      ContractNum = pkanketa.rescha[3].
      City = ''.
      HomePhone = ''.
      BaseAddress[1] = " ". 
	 
      run Put_application.
      run Put_footer.
      run Copyfile.

      find current bkcard exclusive-lock.
      bkcard.sta = 5. /* отправили инфо о клиенте */
      find current bkcard no-lock.

