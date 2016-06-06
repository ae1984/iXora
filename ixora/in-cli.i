/* in-cli.i
 * MODULE
        Отчеты по клиентам
 * DESCRIPTION
        Отчет по внешним клиентам входящих платежей  - ГО и Астана 
 * RUN
        
 * CALLER
        in-cli.p, out-cli.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8-12-7, 8-12-8
 * AUTHOR
        24.02.2004 nadejda - вырезано из in-cli.p
 * CHANGES
        24.02.2004 nadejda - добавлены сведения об получателе - клиенте нашего банка
        17.06.2004 nadejda - добавлена валюта, референс платежа и отбор по списку клиентов
*/

def stream  nur.
def var v-dt1 as date /*init 10/09/01*/ .
def var v-dt2 as date /* init 10/09/01 */.
def var v-amt as decimal init 500000.
def var v-dt as date.
def var v-srnn as char.
def var v-sname as char.
def var v-rrnn as char.
def var v-rname as char.
def var v-sub as integer. 
def var v-ba as char.
def var v-cif as char.
def var v-crc like crc.crc init 1.
def var v-tek as logical format "да/нет" init yes.

form  v-dt1 label " Начало отчетного периода " format "99/99/9999" 
        validate (v-dt1 <= g-today, " Неверная дата начала периода!")
      skip
      v-dt2 label "  Конец отчетного периода " format "99/99/9999" 
        validate (v-dt1 <= v-dt2, " Неверная дата конца периода!")
      skip
      v-amt label "   Сумма платежа не менее " format ">>>,>>>,>>>,>>9.99" 
      skip(1)
      v-crc label "          Валюта платежей " format ">9"
        validate (v-crc = 0 or can-find (crc where crc.crc = v-crc no-lock), " Неверный код валюты!")
        help " 0 - все валюты, или укажите код валюты (F2 - помощь)"
      skip(1)
      v-cif label "Выборка по клиентам Банка " format "x(40)" 
            help " Пусто - все клиенты, или список кодов клиентов через ','"
      skip
      v-tek label " Только расчетные счета ? " 
            help " Только Т/С или с учетом депозитов и ЛОРО"
      skip(1)
      with side-label row 5 centered title " ПАРАМЕТРЫ ОТЧЕТА " frame dat.

v-dt2 = g-today.
v-dt1 = v-dt2 - 61.



if not g-batch then do:
    displ v-dt1 v-dt2 v-amt v-crc v-cif v-tek with frame dat.
    update v-dt1 with frame dat.
    update v-dt2 v-amt v-crc v-cif v-tek with frame dat.
end.
else do:
    v-dt1 = g-today.
    v-dt2 = g-today.
end.     

hide frame dat no-pause.
display "   Ждите...   "  with row 5 frame ww centered overlay.

def temp-table temp  /*workfile*/
    field remtrz as char
    field mfo  as char format "x(9)"
    field acc  as char
    field rnn  as char
    field amt  as deci
    field crc  like crc.crc
    field des  as char
    field dt  as date
    field racc as char
    field rrnn as char
    field rname as char
    index main is primary unique racc acc amt desc remtrz.

def temp-table t-total
  field acc as char
  field total as decimal
  index total is primary unique total desc acc.
 
do v-dt = v-dt1 to v-dt2:
  hide message no-pause.
  message v-dt.

  for each remtrz no-lock where remtrz.valdt2 = v-dt:

    if (remtrz.amt < v-amt) or 
       (v-tek and substr(string(remtrz.{&gl}), 1, 2) <> "22") or 
       (remtrz.jh1 = ?) or 
       (v-crc <> 0 and remtrz.fcrc <> v-crc) or 
       (remtrz.ptype <> v-type) or 
       (remtrz.{&sbank} begins "TXB") then next.

    v-sub = index (remtrz.ord, "/RNN/", 1).
    if v-sub > 0 then do:
      v-srnn = substr(remtrz.ord, (v-sub + 5), 12). /*RNN*/
      v-sname = substr(remtrz.ord, 1, (v-sub - 1)). /* client"s name */
    end.
    else do:
      v-srnn = "".
      v-sname = remtrz.ord.
    end.

    v-rname = trim(remtrz.bn[1]) + trim(remtrz.bn[2]) + trim(remtrz.bn[3]).
    v-sub = index (v-rname, "/RNN/", 1).
    if v-sub > 0 then do:
      v-rrnn = substr(v-rname, (v-sub + 5), 12). /*RNN*/
      v-rname = substr(v-rname, 1, (v-sub - 1)). /* client"s name */
    end.
    else do:
      v-rrnn = "".
    end.

    if remtrz.racc <> "" then v-ba = remtrz.racc.
    else do:
      if substr(remtrz.ba, 1, 1) = '/' then v-ba = substr(remtrz.ba, 2, 9). 
      if substr(remtrz.ba, 10, 1) = '/' then v-ba = substr(remtrz.ba, 1, 9).
      if  substr(remtrz.ba, 1, 1) <> '/' and substr(remtrz.ba, 10, 1)  <> '/' then v-ba = remtrz.ba.
    end.


    create temp.
    assign temp.remtrz = remtrz.remtrz
           temp.mfo = remtrz.{&bank}
           temp.acc  = remtrz.sacc
           temp.rnn  = v-srnn
           temp.amt = remtrz.amt
           temp.crc = remtrz.fcrc
           temp.des = v-sname
           temp.dt = v-dt
           temp.racc = v-ba
           temp.rrnn = v-rrnn
           temp.rname = v-rname.
  end.
end.
hide message no-pause.

