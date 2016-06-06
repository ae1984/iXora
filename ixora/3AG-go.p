/* 3AG-go.p
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
        09.09.2004 tsoy
 * BASES
        BANK COMM
 * CHANGES
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        11.10.2012 Lyubov - перекомпиляция в связи с изменением в chk-rbal

*/

{global.i}
{lgps.i}
{chk-rbal.i}

def shared var s-remtrz like remtrz.remtrz .
def var yn       as log initial false format "да/нет".
def var ok       as log .

def var ourbank  as cha.
def var clearing as cha.
def var vbal     as decimal.
def var valcntrl as logical.
def var brnch as log initial false .
def var v-acc as char.
def var v-rnn as char.
def var v-kbk as integer.

def var is_in_stmt as log .

run checkGW (s-remtrz, output is_in_stmt).

if not is_in_stmt then do:
   Message " Платеж не найден в выписках SWIFT ! Продолжить ? " update yn.
   if not yn then return.
end.


Message " Вы уверены ? " update yn .

if yn then do:
  /* 05.07.2004 tsoy при отзыве платежа в ИО удаляется remtrz, здесь проверяется не удален ли он */
  find first remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
  if not avail remtrz then do:
     message skip "Платеж не найден. Возможно клиент уже отозвал этот платеж  " skip(1) view-as alert-box title " ОШИБКА ! ".
     return.
  end.

  /* 29.12.2003 nadejda - запрет на платежи в пользу Казначейства 31 января */
  if month(remtrz.valdt1) = 12 and day(remtrz.valdt1) = 31 and index(remtrz.rcvinfo[1], "/TAX/") <> 0  then do:
     message skip "Запрещены казначейские платежи в последний день года!" skip(1) view-as alert-box title " ОШИБКА ! ".
     return.
  end.

  /* 30.12.2003 nadejda - проверка на просрочку на счетах Д/В потребкредитования - если да, то дебетовые операции запрещены */
  run chkdolg (remtrz.sacc, output vbal).

  /* если есть просрочка - запретить транзакцию ! */
  if vbal > 0 then do:
    message skip " Счет" remtrz.sacc "принадлежит Департаменту Потреб.кредитования," skip
            " по связанному кредиту обнаружена просроченная задолженность !" skip(1)
            " Дебетовые операции по счету запрещены, кроме погашения ссуды ! " skip(1)
            view-as alert-box button ok title " ВНИМАНИЕ ! ".
    return.
  end.
  vbal = 0.
  /**************************************************/

def var v-knp as char init ''.
def var v-pr as log init 'true'.
/* контроль на заполнение кода ЕКНП */
find sub-cod where sub-cod.acc = s-remtrz
                   and sub-cod.sub = 'rmz'
                   and sub-cod.d-cod = 'eknp'
                   and sub-cod.ccode = 'eknp'
                   and sub-cod.rcode ne ' ' no-lock no-error.
     if not avail sub-cod then v-pr = false.
     else
        if (entry(1,sub-cod.rcode,',') eq ''
        or entry(2,sub-cod.rcode,',') eq ''
        or entry(3,sub-cod.rcode,',') eq '') then v-pr = false.
     if not v-pr then do:
        message "Необходимо проставить коды ЕКНП (см.опцию 'Справочник')!".
        pause.
        return.
      end.

      v-knp = entry(3, sub-cod.rcode, ',').
 end.

/*** KOVAL Контроль на остаток дебитуемого счета RMZ ***/
 if m_pid = "3A" then do:
   vbal = chk-rbal(s-remtrz).

   if vbal = ? or vbal < 0 then do:
      v-text = "3-go: Ошибка контроля остатка (" + string(vbal) + ") с помощью chk-rbal.i".
      run lgps .
      input clear. /* Очистим буфер клавиатуры */
      MESSAGE "Остаток на счете равен " vbal "~nПродолжить?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Внимание !!!"
      UPDATE valcntrl.
      case valcntrl:
        when true  then v-text = s-remtrz + " " + g-ofc + " АКЦЕПТОВАЛ платеж с остатком на счете равным " + string(vbal).
        when false then do:
                      v-text = s-remtrz + " " + g-ofc + " НЕ АКЦЕПТОВАЛ платеж т.к. остаток на счете равен " + string(vbal).
                      run lgps .
                      return.
        end.
      end case.
      run lgps .
   end.
 end.
/*** KOVAL Контроль на остаток дебитуемого счета RMZ ***/


/* 06.05.2004 nadejda - проверка реквизитов НК для налоговых платежей */
v-acc = entry(1, trim(remtrz.ba, "/"), "/").

if (v-acc matches "...080..." or v-acc matches "...144...") and (v-knp begins '9') then do:


  if num-entries(trim(remtrz.ba, "/"), "/") < 2 then do:
    message skip " Неверный код бюджетной классификации !" skip(1)
            view-as alert-box button ok title " ВНИМАНИЕ ! ".
    return.
  end.

  v-kbk = integer (entry(2, trim(remtrz.ba, "/"), "/")) no-error.
  if error-status:error then do:
    message skip " Неверный код бюджетной классификации !" skip(1)
            view-as alert-box button ok title " ВНИМАНИЕ ! ".
    return.
  end.

  find budcodes where budcodes.code = v-kbk no-lock no-error.
  if not avail budcodes then do:
    message skip " Неверный код бюджетной классификации !" skip(1)
            view-as alert-box button ok title " ВНИМАНИЕ ! ".
    return.
  end.

  if index(remtrz.rcvinfo[1], "/TAX/") = 0 then do:
    message skip " Неверный вид платежа - должен быть налоговый платеж !" skip(1)
            view-as alert-box button ok title " ВНИМАНИЕ ! ".
    return.
  end.

  if v-acc matches "...080..." then do:
    v-rnn = trim(remtrz.ben[1] + remtrz.ben[2] + remtrz.ben[3]).
    v-rnn = trim(substr(v-rnn, index(v-rnn, "/RNN/") + 5)).
    v-rnn = substr(v-rnn, 1, 12).

    find first taxnk where taxnk.rnn = v-rnn no-lock no-error.
    if avail taxnk and (string(taxnk.bik) <> remtrz.rbank or string(taxnk.iik) <> v-acc) then do:
      message skip " Неверные реквизиты налогового комитета !" skip(1)
              view-as alert-box button ok title " ВНИМАНИЕ ! ".
      return.
    end.
  end.
end.
/**/


if remtrz.ptype eq ""  then do:
 Message " Тип платежа еще не определен !! Невозможно отправить " . pause .
 return .
end.
find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " Записи OURBNK нет в sysc файле !!".
  pause .
   undo .
    return .
    end.
    ourbank = sysc.chval.
find sysc where sysc.sysc = "clcen" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display " Записи CLEARING нет в sysc файле !!".
  pause .
   undo .
    return .
    end.
    clearing = sysc.chval.
    if ourbank = clearing  then brnch = false . else brnch = true .


if brnch and remtrz.source = "H" and remtrz.crgl eq ?
then  do:
message "Проведите операцию OUTGOING !!!".
pause.
return.
end.

find current remtrz exclusive-lock.
{koval-vlt.i}
find current remtrz no-lock.

if yn then do transaction :

find first que where que.remtrz = s-remtrz exclusive-lock no-error .

if avail que and ( que.pid ne m_pid or que.con eq "F" ) then  do:
 Message " Вы не владелец !! Отправить невозможно " . pause .
 undo.
 release que .
 return .
end.

if avail que then do :
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock .
  {canbal.i}
  {nbal+r.i}
  que.pid = m_pid.
  if remtrz.jh1 ne ? then
   find first jl where jl.jh = remtrz.jh1 no-lock no-error  .
  if remtrz.jh1 ne ? and avail jl and not remtrz.source begins 'MD'then
    que.rcod = "2".
  else if remtrz.jh1 ne ? and avail jl and remtrz.source begins 'MD'then
    que.rcod = "1".
  else
  que.rcod = "0" .
  v-text = " Отправлен " + remtrz.remtrz + " по маршруту , rcod = " +
  que.rcod +
  " " + remtrz.sbank + " -> " + remtrz.rbank .
  run lgps.
  que.con = "F".
  que.dp = today.
  que.tp = time.
  release que .
end.

{koval-vsd.i}

end .
