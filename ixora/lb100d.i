/* lb100d.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Для программы формирования файла сообщения при выгрузке

        Определение дополнительных переменных из sysc
        Разнос платежей по временным таблицам по виду
 * RUN
        
 * CALLER
        lb100.p, lb100g.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-3-5-10
 * AUTHOR
        20.04.2004 nadejda - вынесено из lb100.p
 * CHANGES
        23.04.2004 nadejda - таможенные платежи на счета ...144... должны идти по старой форме МТ102, по-новому отправляем только ...080...
        25.05.2004 nadejda - таможенное управление не может разобрать новый формат! для них посылаем по-старому 
        27.05.2004 nadejda - нет, все-таки надо и таможенные на 080 счета отправлять в новом формате. Закомментарила предыдущее изменение.
        13.08.2004 sasco   - Таможенное управление Астаны v-racc = "003144872" and remtrz.rbank = "195301070" идет как налоговые 102
        05/04/2005 sasco - добавил индексы
        12/12/05   marinav - добавила КБК = 106105
        26.06.2009 galina - исключила платежи по ОПВ и СО ИР, они обрабатываются в lb102ink.i
*/

/* путь к пенсионкам */
def var v-psjin as char.
find sysc where sysc.sysc = "psjin" no-lock no-error .
if not avail sysc or trim(sysc.chval) = "" then do:
  v-text = " ERROR !!! There isn't record PSJIN in sysc file !! ".
  message v-text.
  run lgps.
  return .
end.
v-psjin = trim(sysc.chval).

/* для отделения налоговых платежей */
def var v-arpmid as char init "076,904".
find sysc where sysc.sysc = "arpmid" no-lock no-error.
if avail sysc then v-arpmid = sysc.chval.

def temp-table t-arpmid
  field mid as char
  index mid is primary unique mid.

do i = 1 to num-entries(v-arpmid):
  create t-arpmid.
  t-arpmid.mid = "..." + entry(i, v-arpmid) + "...".
end.


/* разбор платежей по типам в разные временные таблицы */
def temp-table t-docs like clrdoc
  field sbank as char
  field type as logical
  index main is primary bank sbank type.

/* 01.01.2004 nadejda - подборка налоговых платежей для формирования МТ102 в новом формате */
def new shared temp-table t-rmztax 
  field sbank as char
  field sacc as char
  field rbank as char
  field racc as char
  field kbk as char
  field rnn as char
  field rem as char
  index main sbank sacc rbank racc rnn kbk rem.

def var v-type as char.
def var v-rnn as char.
def var v-kbkcustom as char init "105102,105105,105106,105107,105241,105242,105243,105244,105245,105246,105247,105248,105249,105250,105251,105255,105258,105259,105260,105261,105269,105270,105271,105272,105273,105274,105275,105276,105277,105278,105279,105280,105281,105283,105284,105285,105286,105287,105402,106101,106102,106103,106104,106105,106201,106202,106203,106204,203101".

for each {1} where {1}.rdt = g-today and {1}.pr = vnum no-lock use-index rdtpr by {1}.bank by {1}.amt:

  find first remtrz where remtrz.remtrz = {1}.rem no-lock no-error.
  if not avail remtrz then next.
  if index(remtrz.rcvinfo[1],"/PSJINK/") > 0 then next.
  
  if index(remtrz.rcvinfo[1],"/PSJ/") > 0 then v-type = "psj".
  else do:
    if index(remtrz.rcvinfo[1], "/TAX/") = 0 then v-type = "pay".
    else do:
      vvv = trim(remtrz.ba).
      v-racc = entry(num-entries(vvv, "/") - 1, vvv, "/").
      vvv = entry(num-entries(vvv, "/"), vvv, "/").

      /* по новой форме отправляются только налоговые платежи - на 080 счета! */
      /* 25.05.2004 nadejda - таможенное управление не может разобрать новый формат! для них посылаем по-старому */

      if v-racc matches "...080..." /*and lookup(vvv, v-kbkcustom) = 0*/ 
         or (v-racc = "003144872" and remtrz.rbank = "195301070") /* sasco - Таможенное управление Астаны */
      then do:
        find first t-arpmid where remtrz.sacc matches t-arpmid.mid no-lock no-error.
        if avail t-arpmid then v-type = "tax". 
                          else v-type = "pay".
      end.
      else v-type = "pay".
    end.
  end.

  if v-type = "tax" then do:

    /* РНН получателя */
    v-rnn = trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]).
    n = index (v-rnn, "/RNN/").
    if n = 0 then v-rnn = "".
             else v-rnn = substr(trim(substr(v-rnn, n + 5)), 1, 12).
    
    create t-rmztax.
    assign t-rmztax.sbank = remtrz.sbank
           t-rmztax.sacc = remtrz.sacc
           t-rmztax.rbank = remtrz.rbank
           t-rmztax.racc = remtrz.racc
           t-rmztax.kbk = vvv
           t-rmztax.rem = remtrz.remtrz
           t-rmztax.rnn = v-rnn.
  end.
  else do:
    create t-docs.
    buffer-copy {1} to t-docs.
    t-docs.sbank = remtrz.sbank.
    t-docs.type = (v-type <> "psj"). /* yes - обычный платеж, no - пенсионка */
  end.
end.

