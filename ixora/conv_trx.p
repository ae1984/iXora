/* conv_trx.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Реконвертация на счет
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
        08.06.2005 saltanat
        26.01.2006 Natalya D. добавила вывод ї документа и ї транзакций в лог-файл. Добавила сохранение номера транзакции начисления в таблицу документов
        21.07.2006 Natalya D. добавлено фиксация по реконвертации в таблице curctrl
        
 * CHANGES
*/

{global.i}
{crc-crc.i}

define input  parameter p-vaccno  as char.     /* Вх. параметер счета клиента для снятия средств */
define input  parameter p-taccno  as char.     /* Вх. параметер счета клиента для зачисления средств */
define input  parameter p-vamount as deci.     /* Сумма реконвертации в валюте */ 
define input  parameter p-jh      like jl.jh.  /* Номер проводки начисления */ 
define input  parameter p-sts    like curctrl.sts.  /*статус*/

def var  documN     like dealing_doc.docno label "Номер документа" no-undo.
def var  documType  as integer  no-undo /*тип документа 1 срочная конвертация*/.
def var  vaccno     as char    label "Счет клиента для снятия средств    " format "x(9)" no-undo.
def var  taccno     as char    label "Счет клиента для зачисления средств" format "x(9)" no-undo.
def var  comaccno   as char    label "Счет с которого снимается комиссия " format "x(9)" no-undo.
def var  currency   as integer label "Валюта" format ">9" initial 1 no-undo.
def var  clientno   as char    label "ID клиента" no-undo.
def var  clientname like cif.name    label "Клиент" format "x(45)" no-undo.

def var  avg_tamount     as decimal  no-undo /*format "zzz,zzz,zzz,zzz.99"*/.
def var  diff_tamount    as decimal  no-undo /*format "zzz,zzz,zzz,zzz.99"*/.

def var  tamount    as decimal    label "Сумма на реконвертацию в тенге "  no-undo /*format "zzz,zzz,zzz,zzz.99"*/. 
def var  vamount    as decimal    label "Сумма на реконвертацию в валюте"  no-undo /*format "zzz,zzz,zzz,zzz.99"*/.
def var  famount    as decimal.
def var  urg_com    as decimal    label "Комиссия за срочность        "  no-undo /*format "zzz,zzz,zzz,zzz.99"*/.
def var  conv_com   as decimal    label "Комиссия за реконвертацию    "  no-undo /*format "zzz,zzz,zzz,zzz.99"*/.
def var  birz_com   as decimal    label "Биржевая комиссия            "  no-undo /*format "zzz,zzz,zzz,zzz.99"*/.

def var  litems     as char.
def var  currate    as decimal label "Курс"  no-undo /*format "zzz,zzz.9999"*/.
def var  l-tran     as logical no-undo.  /*да сделать транзакцию*/

def
 new shared var s-jh like jh.jh  no-undo.

def var retval as char no-undo.
def var rcode as int no-undo.
def var rdes  as cha no-undo.
def var dlm as char init "|" no-undo.

def var rem as char initial "1223asfdasdfa" no-undo.
def var cur_time as integer no-undo.
def var ans as logical no-undo.

def var  tamount_proc as decimal  label "Окончательная сумма в тенге  "  no-undo /*format "zzz,zzz,zzz,zzz.99"*/ .
/*Сумма в валюте + ком. за срочность + ком. за конвертацию + биржевая */

def var conv_int as decimal initial "0.1" label "Процент комиссии за реконвертацию"  no-undo. /* Было 0,2 */
def var conv_int_min as decimal initial "0"  label "Минимальная сумма за реконвертацию" no-undo. /* Было 15 */
def var cim_notusd as decimal no-undo. /*используется если валюты не доллары*/
def var urg_int as decimal  initial "0"  label "Процент комиссии за срочность  " no-undo. /* Было 0,2 */
def var birz_int as decimal initial "0" no-undo. /*процент биржевой комиссии*/ /* Было 0,05 */
def var conv_temp as decimal no-undo.
def var urg_temp as decimal no-undo.
def var temp_rate as decimal format "zzz,zzz.9999" no-undo.
def var tfirst as logical no-undo.   /*true если сначала была введена сумма в тенге
                               false если сперва была сумма в валюте */
def var dType as integer initial 3 no-undo.
define variable v-sts like jh.sts  no-undo. 

def buffer dcrc for crc .

define variable m_sub as character initial "dil" no-undo.
def stream s-err.
output stream s-err to dcls64.log append.
{dil_util0.i}

/*do transaction:*/
  
            run Init_vars.

            documn = ''.
            litems = "".
            l-tran = false.

            /*run generate_docno.*/

            find aaa where aaa.aaa eq vaccno no-lock no-error.
            if not available aaa then return. 

            currency = aaa.crc.
            if currency = 1 then return.

            find cif where cif.cif eq aaa.cif no-lock no-error.
            if not available cif then return.

            clientname = trim(trim(cif.prefix) + " " + trim(cif.name)).
            clientno = cif.cif.

            for each aaa where aaa.crc eq 1 and aaa.cif eq clientno and aaa.sta <> 'C' break by aaa.crc:
              find lgr where lgr.lgr = aaa.lgr no-lock no-error.
              if available lgr then if lgr.led <> 'oda' then
              if last-of(aaa.crc) then litems = litems + aaa.aaa.
                                  else litems = litems + aaa.aaa + "|".
            end. 
            if litems = '' then return.
            if taccno = '' then return.
            find crc where crc.crc = currency no-lock no-error.
            if avail crc then do:
            case crc.crc:
                     when 2 then do:
                          find sysc where sysc.sysc = 'ercusd' no-error.
                          currate = sysc.deval.
                     end.
                     when 4 then do:
                          find sysc where sysc.sysc = 'ercrur' no-error.
                          currate = sysc.deval.
                     end.
                     when 11 then do:
                          find sysc where sysc.sysc = 'erceur' no-error.
                          currate = sysc.deval.
                     end.
            end.
            end.
            famount = vamount. run getperc_vamt. tfirst = false. 
                                  
            if check_acc(vaccno,vamount,false) then return.
            if check_acc(comaccno,urg_com + conv_com,true) then return.
            run create_doc. 
            run do_trans.
            
            find curctrl where curctrl.jh = p-jh and curctrl.aaa = p-vaccno and curctrl.sts = p-sts no-error.
            if avail curctrl then do:
               curctrl.rpjdt  = g-today.
               curctrl.rpjh  = s-jh.
               curctrl.rpnumdoc = documN.
            end. else next. 
put stream s-err documN " | " p-jh " | " s-jh  skip.
output stream s-err close.

/*end.*/

procedure Init_Vars:

documN  = ''.   
vaccno  = ''.    
taccno  = ''.   
comaccno = ''.  
currency = 0.  
clientno = ''.  
clientname = ''.
tamount    = 0.
vamount    = 0.
urg_com    = 0.
conv_com   = 0.
birz_com   = 0.


currate = 0.
l-tran = false.

s-jh = 0.



tamount_proc =0.
conv_int = 0.1. /* 0,2 */
conv_int_min = 0. /* 15 */
urg_int = 0. /* 0,2 */

conv_temp = 0.
urg_temp = 0.

vaccno = p-vaccno.
taccno = p-taccno.
comaccno = p-taccno.
vamount = p-vamount. 

end procedure.

procedure do_trans:

{dil_acc.i}

find crc where crc.crc = currency no-lock no-error. 
if avail crc then do:
  avg_tamount = crc.rate[1] * vamount.
  avg_tamount = round(round(avg_tamount,3),2).
  diff_tamount = avg_tamount - tamount.
  release crc.
end.
/*do transaction:*/

s-jh = 0.

if diff_tamount < 0 
   then
     do: 
      run trxgen('dil0045', dlm,  

                string(abs(diff_tamount)) + dlm +
                arpacc  ,

                m_sub, documn, output rcode, output rdes, input-output s-jh).
       if rcode ne 0 then do:
          undo,return.  
       end.  
       run trxsts (input s-jh, input 0, output rcode, output rdes).
       if rcode ne 0 then do:
          undo,return.  
       end.  
     end.

run trxgen('dil0043', dlm,
    
    string(vamount) + dlm +
    string(currency) + dlm +
    string(currate) + dlm + 
    vaccno          + dlm +
    valacc[currency] + dlm +
    "Обязат. автомат. продажа неиспользованной валюты " + string(currate) + dlm +
 
    string(tamount) + dlm +
    arpacc          + dlm +
    taccno          + dlm +
    "Зачисление тенге на счет клиента " + string(currate) + dlm +

    string(conv_temp) + dlm +
    string(temp_rate)  + dlm +
    comaccno         + dlm +    

    string(urg_temp)  + dlm +
    string(temp_rate)  + dlm +
    comaccno + dlm +

    string(vamount)     + dlm +
    string(currency)    + dlm +
    valacc[currency]    + dlm +


    string(avg_tamount) + dlm +
    arpacc,

    m_sub, documn, output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        undo,return.
    end.        
    else
      do:
         run trxsts (input s-jh, input 0, output rcode, output rdes).
         if rcode ne 0 then do:
            undo,return.  
         end.  
         if diff_tamount > 0 
            then
              do: 
               run trxgen('dil0044', dlm,  
                         string(abs(diff_tamount)) + dlm +
                         arpacc,
                         m_sub, documn, output rcode, output rdes, input-output s-jh).
              end.

         if rcode ne 0 then do:
            undo,return.  
         end.
         else do:
           run trxsts (input s-jh, input 6, output rcode, output rdes).
           if rcode ne 0 then do:
              undo,return.  
           end.
         end.
      end.
/*end.*/
end procedure.

procedure getperc_vamt:
   tamount = vamount * currate. 
   urg_com = get_percent(urg_int, vamount). 
   conv_com = get_percent(conv_int, vamount). 
   if currency <> 2 
      then 
        do:
           find first dcrc where dcrc.crc = 2 no-lock no-error.  
           cim_notusd = conv_int_min * dcrc.rate[1].
           find first dcrc where dcrc.crc = currency no-lock no-error.           
           cim_notusd = cim_notusd / dcrc.rate[1].
                if conv_com <= cim_notusd 
                   then 
                     do:
                        conv_com = cim_notusd. 
                        run calc_comm(input dcrc.rate[1]).
                     end.
                   else
                     do:
                        run calc_comm(input currate).
                     end.
        end.
      else
        do:
                 if conv_com <= conv_int_min 
                    then 
                      do:
                         conv_com = conv_int_min. 
                         find first dcrc where dcrc.crc = currency no-lock no-error.
                         run calc_comm(input dcrc.rate[1]).
                      end.
                    else
                      do:
                         run calc_comm(input currate).
                      end.  
        end.
end procedure.

procedure create_doc:

  find dealing_doc where dealing_doc.docno = documn and dealing_doc.doctype = dType share-lock no-error .
  if not available dealing_doc 
     then 
       do:
          create dealing_doc.
          dealing_doc.docno = DocumN.
          dealing_doc.crc = crc.crc.
          dealing_doc.doctype = 3. 
          if (vamount = ?) or (vamount = 0) 
             then do: 
               return.
             end.   
          dealing_doc.v_amount = vamount.
          dealing_doc.t_amount = tamount.
          dealing_doc.tclientaccno = taccno.
          dealing_doc.vclientaccno = vaccno.
          dealing_doc.com_expr = urg_com.
          dealing_doc.com_conv = conv_com.
          dealing_doc.whn_cr = g-today.
          dealing_doc.who_cr = g-ofc .
          dealing_doc.whn_mod = g-today.
          dealing_doc.who_mod = g-ofc.
          cur_time = time.
          dealing_doc.time_cr = cur_time.
          dealing_doc.time_mod = cur_time.
          dealing_doc.rate = currate.
          dealing_doc.TngToVal = tfirst.
          dealing_doc.com_accno = comaccno.  
          dealing_doc.f_amount = famount.
          dealing_doc.jh       = s-jh.  
          dealing_doc.jh2      = p-jh.
       end.
end procedure.

procedure calc_comm:
define input parameter t_rate like currate.

find first aaa where aaa.aaa eq comaccno no-lock no-error.
if available aaa 
   then do:
     if aaa.crc = 1 then 
                     do:
                        conv_temp = conv_com * t_rate.
                        urg_temp = urg_com * currate.
                        temp_rate  = 1.0000.
                     end.
                   else
                     do:
                        urg_temp = urg_com.
                        conv_temp = conv_com.
                        temp_rate  = currate.
                     end. 
     end.
end procedure.

