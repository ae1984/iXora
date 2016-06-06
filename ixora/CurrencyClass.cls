/* CurrencyClass.cls
 * MODULE

 * DESCRIPTION
        Класс валют - работа с валютами
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список функций класса

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM
 * AUTHOR
        25.12.2008 k.gitalov
 * CHANGES
        09.06.2009 id00205 добавил переменную Count
        06.09.2011 k.gitalov добавил валюты SEK AUD CHF по СЗ от 06.09.2011
        15.05.2012 k.gitalov добавил валюту ZAR по сз от 14.05.2012
        09.07.2012 damir - добавил валюту CAD по сз от 14.05.2012.
        13.09.2012 damir - добавил no-lock.
*/


CLASS CurrencyClass:
 def public var Count as int. /* Кол-во используемых валют */
 DEFINE private VARIABLE GlobalVar AS CLASS GlobalClass.
 /*************************************************************************************************************/
 CONSTRUCTOR  public CurrencyClass():
    Count = GetCrcCount().
 END CONSTRUCTOR.
 /*************************************************************************************************************/
 CONSTRUCTOR  public CurrencyClass(INPUT std AS CLASS GlobalClass):
    Count = GetCrcCount().
    GlobalVar = std.
 END CONSTRUCTOR.
 /*************************************************************************************************************/
 DESTRUCTOR  public CurrencyClass():

 END DESTRUCTOR.
 /*************************************************************************************************************/
 method private int GetCrcCount():
   def var I as int init 0.
   for each crc no-lock:
    I = I + 1.
   end.
   return I.
 end method.
 /***************************************************************************************************************/
 /* возвращает кол-во процентов 'perc' от числа 'amount' */
 method public decimal GetPercent (INPUT amount as decimal , INPUT perc as decimal):
   return ((amount * perc) / 100).
 end method.
/***************************************************************************************************************/
/* Перевод суммы из одной валюты в другую (курс Нац Банка)*/
 method public decimal crc-crc (sum as decimal, c1 as int, c2 as int):
 define buffer bcrc1 for crc.
 define buffer bcrc2 for crc.
    if c1 <> c2 then
       do:
          find first bcrc1 where bcrc1.crc = c1 no-lock no-error.
          find first bcrc2 where bcrc2.crc = c2 no-lock no-error.
          if avail bcrc1 and avail bcrc2 then return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.

 end method.
/***************************************************************************************************************/
/* Возвращает курсовую разницу для суммы sum_v в валюте c1 по отношению к сумме в тенге sum_t */
 method public decimal DifCourse (sum_t as decimal,sum_v as decimal, c1 as int):
  define buffer bcrc1 for crc.
  def var  avg_tamount  as decimal  format "zzz,zzz,zzz,zzz.99" no-undo. /* Сумма в тенге по курсу Нац Банка*/
  def var  diff_tamount as decimal  format "zzz,zzz,zzz,zzz.99" no-undo. /* Курсовая разница*/

  find first bcrc1 where bcrc1.crc = c1 no-lock no-error.
   avg_tamount = bcrc1.rate[1] * sum_v.
   avg_tamount = round(round(avg_tamount,3),2).
   diff_tamount = avg_tamount - sum_t.
  return diff_tamount.

 end method.
/***************************************************************************************************************/
/* Возвращает курс Нац Банка для валюты c1 */
 method public decimal nBankRate(c1 as int):
   define buffer bcrc1 for crc.
   find first bcrc1 where bcrc1.crc = c1 no-lock no-error.
   return bcrc1.rate[1].
 end method.
/***************************************************************************************************************/
 /* Возвращает сумму в тенге для суммы sum_v в валюте c1 по курсу нац банка*/
 method public decimal NB-sale-rate( sum_v as decimal, c1 as int):
   define buffer bcrc1 for crc.
   def var  avg_tamount  as decimal  format "zzz,zzz,zzz,zzz.99" no-undo. /* Сумма в тенге по курсу Нац Банка*/

   find first bcrc1 where bcrc1.crc = c1 no-lock no-error.
    avg_tamount = bcrc1.rate[1] * sum_v.
    avg_tamount = round(round(avg_tamount,3),2).
   return avg_tamount.
 end method.
/***************************************************************************************************************/
/* Перевод суммы из одной валюты в другую по курсу на определенную дату */
 method public decimal crc-crc-date (sum as decimal, c1 as int, c2 as int, d1 as date):
 define buffer bcrc1 for crchis.
 define buffer bcrc2 for crchis.
    if c1 <> c2 then
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          if avail bcrc1 and avail bcrc2 then return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.

 end method.
/***************************************************************************************************************/
/* Возвращает валюту указанного счета */
 method public int get-crc ( acc as char):
  def var cur as int init 0.
  def buffer b-aaa for aaa.
   find first b-aaa where b-aaa.aaa = acc  no-lock no-error.
   if avail b-aaa then cur = b-aaa.crc.
  return cur.
 end method.
/***************************************************************************************************************/
/* Возвращает курс продажи Банком указанной валюты при срочной конвертации (биржевой)*/
 method public decimal get-exp-sale-rate ( currency as int):
   def var rate as decimal format "zzz,zzz.9999".
   def buffer b-sysc for sysc.
     case currency:
       when 2  then find b-sysc where b-sysc.sysc = 'ecusd' no-lock no-error.
       when 3  then find b-sysc where b-sysc.sysc = 'eceur' no-lock no-error.
       when 4  then find b-sysc where b-sysc.sysc = 'ecrur' no-lock no-error.
       when 6  then find b-sysc where b-sysc.sysc = 'ecgbp' no-lock no-error.
       when 7  then find b-sysc where b-sysc.sysc = 'ecsek' no-lock no-error.
       when 8  then find b-sysc where b-sysc.sysc = 'ecaud' no-lock no-error.
       when 9  then find b-sysc where b-sysc.sysc = 'ecchf' no-lock no-error.
       when 10 then find b-sysc where b-sysc.sysc = 'eczar' no-lock no-error.
       when 11 then find b-sysc where b-sysc.sysc = 'eccad' no-lock no-error.
      end.
     rate = b-sysc.deval.
   return rate.
 end method.
/***************************************************************************************************************/
/* Возвращает курс продажи Банком указанной валюты при обычной конвертации (биржевой)*/
 method public decimal get-std-sale-rate ( currency as int):
   def var rate as decimal format "zzz,zzz.9999".
   def buffer b-sysc for sysc.
     case currency:
       when 2  then find b-sysc where b-sysc.sysc = 'ocusd' no-lock no-error.
       when 3  then find b-sysc where b-sysc.sysc = 'oceur' no-lock no-error.
       when 4  then find b-sysc where b-sysc.sysc = 'ocrur' no-lock no-error.
       when 6  then find b-sysc where b-sysc.sysc = 'ocgbp' no-lock no-error.
       when 7  then find b-sysc where b-sysc.sysc = 'ocsek' no-lock no-error.
       when 8  then find b-sysc where b-sysc.sysc = 'ocaud' no-lock no-error.
       when 9  then find b-sysc where b-sysc.sysc = 'occhf' no-lock no-error.
       when 10 then find b-sysc where b-sysc.sysc = 'oczar' no-lock no-error.
       when 11 then find b-sysc where b-sysc.sysc = 'occad' no-lock no-error.
      end.
     rate = b-sysc.deval.
   return rate.
 end method.
/***************************************************************************************************************/
/* Возвращает курс покупки Банком указанной валюты при обычной реконвертации (биржевой)*/
 method public decimal get-std-purch-rate ( currency as int):
   def var rate as decimal format "zzz,zzz.9999".
   def buffer b-sysc for sysc.
     case currency:
      when 2  then find b-sysc where b-sysc.sysc = 'orcusd' no-lock no-error.
      when 3  then find b-sysc where b-sysc.sysc = 'orceur' no-lock no-error.
      when 4  then find b-sysc where b-sysc.sysc = 'orcrur' no-lock no-error.
      when 6  then find b-sysc where b-sysc.sysc = 'orcgbp' no-lock no-error.
      when 7  then find b-sysc where b-sysc.sysc = 'orcsek' no-lock no-error.
      when 8  then find b-sysc where b-sysc.sysc = 'orcaud' no-lock no-error.
      when 9  then find b-sysc where b-sysc.sysc = 'orcchf' no-lock no-error.
      when 10 then find b-sysc where b-sysc.sysc = 'orczar' no-lock no-error.
      when 11 then find b-sysc where b-sysc.sysc = 'orccad' no-lock no-error.
     end.
      rate = b-sysc.deval.
   return rate.
 end method.
/***************************************************************************************************************/
/* Возвращает курс покупки Банком указанной валюты при срочной реконвертации (биржевой)*/
 method public decimal get-exp-purch-rate ( currency as int):
   def var rate as decimal format "zzz,zzz.9999".
   def buffer b-sysc for sysc.
     case currency:
      when 2  then find b-sysc where b-sysc.sysc = 'ercusd' no-lock no-error.
      when 3  then find b-sysc where b-sysc.sysc = 'erceur' no-lock no-error.
      when 4  then find b-sysc where b-sysc.sysc = 'ercrur' no-lock no-error.
      when 6  then find b-sysc where b-sysc.sysc = 'ercgbp' no-lock no-error.
      when 7  then find b-sysc where b-sysc.sysc = 'ercsek' no-lock no-error.
      when 8  then find b-sysc where b-sysc.sysc = 'ercaud' no-lock no-error.
      when 9  then find b-sysc where b-sysc.sysc = 'ercchf' no-lock no-error.
      when 10 then find b-sysc where b-sysc.sysc = 'erczar' no-lock no-error.
      when 11 then find b-sysc where b-sysc.sysc = 'erccad' no-lock no-error.
     end.
      rate = b-sysc.deval.
   return rate.
 end method.
/***************************************************************************************************************/
/* Возвращает кросс курс двух валют */
 method public decimal get-cross-rate (cur1 as int, cur2 as int):
    def var v-sysc as char.
    def var rate as decimal format "zzz,zzz.9999".
    def buffer b-sysc for sysc.
    v-sysc = string(cur1) + "to" + string(cur2) + "c".
           find b-sysc where b-sysc.sysc = v-sysc no-lock no-error.
           if avail b-sysc then rate = decimal(b-sysc.chval).
           else rate = -1.
    return rate.
 end method.
/***************************************************************************************************************/

/* Возвращает символьный код валюты по ID валюты */
 method public char get-code (  currency as int ):
  def var code as char format "x(3)".
  def buffer b-crc for crc.
   find b-crc where b-crc.crc = currency no-lock no-error.
   if avail b-crc then do:
     code = b-crc.code.
   end.
   else code = "?".
  return code.
 end method.
/***************************************************************************************************************/
/* Возвращает ID валюты по символьному коду */
 method public int get-id-crc (  currency as char ):
  def var code as int.
  def buffer b-crc for crc.
   find b-crc where b-crc.code = currency no-lock no-error.
   if avail b-crc then do:
     code = b-crc.crc.
   end.
   else do: message "Не найден код валюты !" view-as alert-box. code = 0. end.
  return code.
 end method.
/***************************************************************************************************************/
/* Возвращает символьный код валюты по номеру счета клиента */
 method public char get-code ( acc as char ):
  def var code as char format "x(3)".
  def buffer b-crc for crc.
  def buffer b-aaa for aaa.
   find first b-aaa where b-aaa.aaa = acc  no-lock no-error.
   if avail b-aaa then do:
    find b-crc where b-crc.crc = b-aaa.crc no-lock no-error.
    if avail b-crc then do:
     code = b-crc.code.
    end.
    else code = "?".
   end.
  return code.
 end method.
/***************************************************************************************************************/
 /* Возвращает VIP курс продажи Банком валюты для клиента если он установлен */
 method public decimal get-vip-sale-rate ( clientno as char, currency as int, output id as int ):
  if not VALID-OBJECT(GlobalVar) then do: message "get-vip-sale-rate - не инициализирован объект GlobalVar!" view-as alert-box. return -1. end.
  def var rate as decimal format "zzz,zzz.9999".
  def var oper as char.
  rate = -1.
  oper = "1_" +  STRING(currency).
    find first viprate where viprate.cif = clientno and viprate.del = no and viprate.valid_to >= GlobalVar:g-today and viprate.oper = oper no-lock no-error.
    if avail viprate then
    do:
      rate = viprate.rate.
      id = viprate.idrate.
    end.
  return rate.
 end method.
/***************************************************************************************************************/
 /* Возвращает VIP курс покупки Банком валюты у клиента если он установлен */
 method public decimal get-vip-purch-rate ( clientno as char, currency as int, output id as int ):
  if not VALID-OBJECT(GlobalVar) then do: message "get-vip-purch-rate - не инициализирован объект GlobalVar!" view-as alert-box. return -1. end.
  def var rate as decimal format "zzz,zzz.9999".
  def var oper as char.
  rate = -1.
  oper = STRING(currency) + "_1".
    find first viprate where viprate.cif = clientno and viprate.del = no and viprate.valid_to >= GlobalVar:g-today and viprate.oper = oper no-lock no-error.
    if avail viprate then
    do:
      rate = viprate.rate.
      id = viprate.idrate.
    end.
  return rate.
 end method.
/***************************************************************************************************************/
 /* Возвращает VIP кросс курс обмена валют для клиента если он установлен */
 method public decimal get-vip-cross-rate ( clientno as char, cur1 as int, cur2 as int, output id as int ):
  if not VALID-OBJECT(GlobalVar) then do: message "get-vip-cross-rate - не инициализирован объект GlobalVar!" view-as alert-box. return -1. end.
  def var rate as decimal format "zzz,zzz.9999".
  def var oper as char.
  rate = -1.
  oper = STRING(cur1) + "_" + STRING(cur2).
    find first viprate where viprate.cif = clientno and viprate.del = no and viprate.valid_to >= GlobalVar:g-today and viprate.oper = oper no-lock no-error.
    if avail viprate then
    do:
      rate = viprate.rate.
      id = viprate.idrate.
    end.
  return rate.
 end method.
/***************************************************************************************************************/
END CLASS.





