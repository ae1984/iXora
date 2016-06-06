
/* lnpriv.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Справочник организаций со спецусловиями кредитования
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        19/09/2008 galina
 * BASES
        BANK COMM
 * CHANGES
*/


def input parameter p-credtype as char.
def var v-rnn as char.
def var v-name as char.
def var v-ctnum as char.
def var v-dt1 as date.
def var v-dt2 as date.
def var v-rateq as deci.
def var v-comacc as deci.
def var v-compay as deci.
def var v-rid as rowid.

define buffer b-lnpriv1 for lnpriv.
define buffer b-lnpriv for lnpriv.

/*для вывода отчета*/
def stream rep.
def var i as integer.    
def var v-bank as char.
def new shared var v-dt as date.
def temp-table t-rep
 field rnn as char
 field name as char
 field dt1 as date
 field dt2 as date
 field ctnum as char          
 field rateq as deci 
 field comacc as deci
 field compay as deci
 field ofc as char.
 
def var msg-err as char.

define button brep label "Отчет".
{global.i}

function chk-ctnum return char (p-ctnum as char).
 def var s as char.
 s = ''.
 if (p-ctnum) = "" then do:
    s = '*'.
    msg-err = "Введите номер договора!".
 end.
 if can-find(b-lnpriv1 where b-lnpriv1.ctnum = trim(p-ctnum) and b-lnpriv1.bank = lnpriv.bank and b-lnpriv1.credtype = lnpriv.credtype 
 and ((b-lnpriv1.dtb <> lnpriv.dtb and b-lnpriv1.rnn = lnpriv.rnn) or b-lnpriv1.rnn <> lnpriv.rnn) no-lock) then do:
   s = '*'.
   msg-err = "Соглашения с таким номером уже зарегистрировано!".
 end.  
 return s.
end.

find last ofchis where ofchis.ofc = g-ofc no-lock no-error.
 if not avail ofchis then do:
  message 'Нет сведений о пользователе!!!' view-as alert-box.
  return.
end.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc then do:
 message "Отсутствует запись OURBNK в sysc!" view-as alert-box.
 return.
end.
v-bank = sysc.chval.

for each lnpriv where lnpriv.rnn = "" exclusive-lock:
  delete lnpriv.
end.

define query qt for lnpriv.
define browse bt query qt
       displ lnpriv.rnn label "РНН" format "999999999999"
       lnpriv.name label "Наименование" format "x(20)"
       lnpriv.ctnum label "N договора" format "x(10)"
       lnpriv.dtb label "Дата закл.соглаш." format "99/99/9999"
       lnpriv.dte label "Дата заверш.соглаш." format "99/99/9999"
 with 10 down no-label no-box.
 
define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <F4>-Выход" skip " " brep with width 100 row 3 column 10 no-label title "Организации со спец.условиями кредитования".
form
  v-rnn label "РНН" format "999999999999"  validate(length(v-rnn) = 12, 'Количество цифр должно быть равно 12!') skip
  v-name label "Наименование" format "x(40)" validate(length(trim(v-name)) > 0,'Введите наименование!') skip
  v-ctnum label "Номер договора" format "x(20)" validate(chk-ctnum(v-ctnum) = "", msg-err) skip
  v-dt1 label "Дата закл.соглашения" format "99/99/9999" validate(v-dt1 <> ? ,'Введите дату закл.соглашения!') skip
  v-rateq label "Процентная ставка" format ">>9.99" validate(v-rateq > 0,'Ставка не может быть равна нулю!') skip
  v-comacc label "Комиссия за ведение счета" format ">>9.99" skip
  v-compay label "Комиссия за выдачу кредита" format ">>9.99" skip
  v-dt2 label "Дата заверш.соглашения" format "99/99/9999" validate(v-dt2 <> ? ,'Введите дату заверш.соглашения!') skip
with side-label  row 3 width 80 title "РЕДАКТИРОВАНИЕ "  frame fedit.

on "return" of bt in frame ft do: 
    find last b-lnpriv where b-lnpriv.credtype = lnpriv.credtype and b-lnpriv.bank = lnpriv.bank 
                             and b-lnpriv.rnn = lnpriv.rnn and b-lnpriv.ctnum = lnpriv.ctnum no-lock no-error.
    if avail b-lnpriv then do:
       assign
          v-rnn = b-lnpriv.rnn
          v-name = b-lnpriv.name
          v-dt1 = b-lnpriv.dtb
          v-dt2 = b-lnpriv.dte
          v-ctnum = b-lnpriv.ctnum
          v-rateq = b-lnpriv.rateq
          v-comacc = b-lnpriv.comacc
          v-compay = b-lnpriv.compay.
          
       display v-dt2 with frame fedit.         
       update v-rnn v-name v-ctnum v-dt1 v-rateq v-comacc v-compay with frame fedit.      
       
       repeat: 
         update v-dt2 with frame fedit.      
         if v-dt2 > v-dt1 then leave.
         else message 'Дата заверш.соглашения должна быть больше или равна даты закл.соглашения!'.
       end.  
       find current b-lnpriv exclusive-lock.
       assign
          b-lnpriv.rnn = v-rnn
          b-lnpriv.name = v-name
          b-lnpriv.dtb = v-dt1
          b-lnpriv.dte = v-dt2
          b-lnpriv.ctnum = v-ctnum
          b-lnpriv.rateq = v-rateq
          b-lnpriv.comacc = v-comacc
          b-lnpriv.compay = v-compay.
      find current b-lnpriv no-lock.
    end.
    find first b-lnpriv no-lock no-error.
    open query qt for each lnpriv no-lock.
    if avail b-lnpriv then bt:refresh().
end.  

on "insert-mode" of bt in frame ft do:
    create lnpriv.
    assign
      lnpriv.who = g-ofc
      lnpriv.whn = g-today
      lnpriv.bank = v-bank
      lnpriv.credtype = "6".

    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(lnpriv).
    open query qt for each lnpriv  no-lock.
    reposition qt to rowid v-rid no-error.
    bt:refresh().
    apply "return" to bt in frame ft.
end.

/*вывод отчета*/
on choose of brep in frame ft do:
    form 
     v-dt label "Дата" format "99/99/9999" skip
    with side-label centered title "ПАРАМЕТРЫ ОТЧЕТА"  frame frep. 
    v-dt = g-today.
    update v-dt with frame frep.
    hide frame frep.
    
   empty temp-table t-rep.  
   for each lnpriv where lnpriv.credtype = p-credtype and (lnpriv.bank = v-bank or v-bank = "TXB00") and (v-dt >= lnpriv.dtb and lnpriv.dte >= v-dt) no-lock:
     create t-rep.
     assign 
       t-rep.rnn = lnpriv.rnn
       t-rep.name = lnpriv.name
       t-rep.dt1 = lnpriv.dtb
       t-rep.dt2 = lnpriv.dte
       t-rep.ctnum = lnpriv.ctnum
       t-rep.rateq = lnpriv.rateq
       t-rep.comacc = lnpriv.comacc
       t-rep.compay = lnpriv.compay
       t-rep.ofc = lnpriv.who.
       

   end.
    
    output stream rep to value("lnpriv" + p-credtype + ".xls").
    find first t-rep no-lock no-error.
    if avail t-rep then do:
           {html-title.i 
             &stream = " stream rep "
             &size-add = "xx-"
             &title = "Справочник по заключенным соглашениям"
            }
            
        put stream rep unformatted "<P align=""left"" style=""font-family:Arial; font-size:11.0pt""><I><B>Справочник по заключенным соглашениям</B></I></P>"  skip.
        put stream rep unformatted  "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"" style=""font-family:Arial; font-size:11.0pt"">" 
             "<TR align=""center"" style=""font:bold"" valign=""center"">" skip
             "<TD>№</TD>" skip
             "<TD>РНН организации</TD>" skip
             "<TD>Наименование<BR>организации</TD>" skip
             "<TD>№ договора</TD>" skip
             "<TD>Дата заключения<BR>соглашения</TD>" skip
             "<TD>% ставка</TD>" skip
             "<TD>Комиссия за<BR>ведение счета<BR>(ежемесячно от<BR>суммы займа)</TD>" skip
             "<TD>Комиссия за<BR>выдачу кредита</TD>" skip
             "<TD>Дата завершения<BR>соглашения</TD>" skip
             "<TD>Логин<BR>исполнителя</TD>" skip
             "</TR>" skip.
        i = 0.      
        for each t-rep no-lock:
          i = i + 1.
          put stream rep unformatted
          "<TR align=""center"">" skip 
          "<TD>" i "</TD>" skip
          "<TD>&nbsp;" t-rep.rnn "</TD>" skip
          "<TD>" t-rep.name "</TD>" skip
          "<TD>" t-rep.ctnum "</TD>" skip
          "<TD>" string(t-rep.dt1,'99.99.9999') "</TD>" skip
          "<TD>" replace(string(t-rep.rateq,'>>9.99'),'.',',') "</TD>" skip
          "<TD>" replace(string(t-rep.comacc,'>>9.99'),'.',',') "</TD>" skip
          "<TD>" replace(string(t-rep.compay,'>>9.99'),'.',',')"</TD>" skip
          "<TD>" string(t-rep.dt2,'99.99.9999') "</TD>" skip
          "<TD>" t-rep.ofc "</TD>" skip
          "</TR>" skip.  
        end.     
        
        put stream rep unformatted "</TABLE>" skip.
        {html-end.i}
      
         output stream rep close.
         unix silent value("cptwin lnpriv" + p-credtype + ".xls excel").
         unix silent value("rm -f lnpriv" + p-credtype + ".xls").
    end.    
end.

open query qt for each lnpriv no-lock.
enable bt  brep with frame ft.
WAIT-FOR  window-close of current-window.
hide frame ft.



