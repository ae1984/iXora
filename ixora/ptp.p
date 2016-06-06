/* ptp.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Формирование ПТП
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
        28/09/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        02/10/2009 galina - добавила слово "года" в дате ПТП
        07/10/2009 galina - добавила слово "года" в дате ПТП
*/

{global.i}
{comm-txb.i}
def var v-cif like cif.cif no-undo.
def var v-cbankl as char no-undo.
def var v-iik as char no-undo.
def var v-name as char no-undo.
def var v-rnn as char no-undo.
def var v-rid as rowid.
def var v-ridptp  as rowid.
def var v-new as logi init no.
def var v-choice as logi init no.
def var v-ptpnum as integer no-undo.
def var v-ptpreg as integer no-undo.
def var v-ptpcln as integer no-undo.
def var v-select as integer no-undo.
def var v-ourbank as char no-undo.
def var v-days_od as integer no-undo.
def var v-days_prc as integer no-undo.
def var i as integer no-undo.
def var v-newptp as logi init no.
def var v-bic as char no-undo.
def var v-sbname as char no-undo.
def var v-rbank as char no-undo.
def var v-rbname as char no-undo.
def var v-rbiik as char no-undo.
def var v-rbrnn as char no-undo.
def var v-kod as integer no-undo.
def var v-kbe as integer no-undo.
def var v-knp as integer no-undo.
def var v-ptpdt as date no-undo.
def var v-ptpsum as deci no-undo.
def var v-rstnum as integer no-undo.
def var v-sts as integer no-undo.
def var v-stsold as integer no-undo.
def var v-stsrem as char no-undo.
def var v-ptprem as char no-undo.
def var v-dt as date no-undo.
def var v-chif as char no-undo.
def var v-mainbk as char no-undo.
def var v-dtch as char no-undo.
def var v-month as char no-undo init 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря'.
def var v-infile as char no-undo.
def var v-ofile as char no-undo.
def var v-sumwrd as char no-undo.
def var v-sum1 as char no-undo.
def var v-sum2 as char no-undo.
def var v-sumch as char no-undo.
def var v-crc1 as char no-undo.
def var v-crc2 as char no-undo.
def stream v-out.
def var v-str as char no-undo.
def var j as integer no-undo.
def var v-totsum as deci no-undo.
def var v-ptpch as char no-undo.
{sysc.i}



def temp-table t-delptpcln
    field ptpcln as integer
    field cif as char
    field bank as char.

def temp-table t-ptpcln
    field ptpcln as integer
    field cif as char
    field name as char
    field rnn as char
    field bic as char
    field iik as char
    field bank as char
    field rwho as char
    field rdt as date.

def temp-table t-ptp
    field ptp as integer
    field cif like cif.cif
    field bank as char
    field name as char
    field rnn as char
    field bic as char
    field sbname as char
    field iik as char
    field rbank as char
    field rbiik as char
    field rbrnn as char
    field kod as integer
    field kbe as integer
    field knp as integer
    field sum as deci
    field rstnum as integer 
    field sts as integer 
    field stsrem as char 
    field ptprem as char
    field date as date
    field rwho as char
    field rdt as date
    field stswho as char
    field stsdt as date.

    
def temp-table t-delptp
    field ptp as integer
    field cif like cif.cif
    field bank as char.
    
form 
    v-ptpnum label 'Номер ПТП' colon 22 format ">>>>>99999" validate(not(can-find(ptp where ptp.ptp = v-ptpnum no-lock)) and v-ptpnum > 0,'ПТП с таким номером уже существует!!')
    v-cif label 'Клиент#' colon 50 format "x(6)" help "F2 - Поиск" validate(can-find(cif where cif.cif = v-cif no-lock),'Клиент не найден!')
    v-name label 'ФИО' colon 22 format "x(40)" skip
    v-rnn label 'РНН' colon 22 format "x(12)" skip
    
    '----------------------------------Бакн отправитель---------------------------' at 10  skip
    v-bic label 'БИК' colon 22 format  "x(12)"  help "F2 - Поиск" validate(can-find(ptpcln where ptpcln.bank = v-ourbank and ptpcln.cif = v-cif and ptpcln.bic = v-bic no-lock),'Не найдены реквизиты задолжника!')
    v-sbname label 'Наименование'  colon 50 format "x(40)" skip
    v-iik label 'ИИК' colon 22 format "x(20)" skip
    '----------------------------------Бакн получатель----------------------------' at 10  skip
    v-rbank label 'БИК' colon 22 format "x(12)" 
    v-rbname label 'Наименование' colon 50 format "x(40)" skip
    v-rbrnn label 'РНН' colon 22 format "x(12)" 
    v-rbiik label 'ИИК' colon 50 format "x(20)" skip
    '-----------------------------------------------------------------------------' at 10 skip
    v-kod label 'КОД' colon 22 format "99"
    v-kbe label 'КБЕ'  format "99"
    v-knp label 'КНП' colon 50 format "999"
    v-rstnum label 'Номер реестра' format "99999" skip
    
    v-ptpdt label 'Дата ПТП' colon 22 format "99/99/9999" 
    v-ptpsum label 'Сумма ПТП' colon 50 format ">>>>>>>>>>>>9.99"
    
    v-sts label 'Статус ПТП' colon 22 format "9" help "0 - Не исп; 1 - Исп.; 2 - Отозв.; 3 - Возвращ." validate(v-sts < 4 ,'Не верный статус ПТП!')
    v-stsrem label 'Примечание к статусу' colon 22 format "x(40)" validate(trim(v-stsrem) <> '' ,'Введите примечание!') skip
    v-ptprem label 'Назначение платежа' colon 22  view-as editor size 40 by 4 skip
with centered side-label width 95 row 5 title "ПАРАМЕТРЫ ПТП" frame f-ptp.

form 
  v-ptpreg label "Номер реестра" format ">>>>>99999" skip
  v-cif label "Клиент" format "x(6)" help "F2 - Поиск" validate(can-find(cif where cif.cif = v-cif no-lock),'Клиент не найден!') 
  v-name label " ФИО"  format "x(40)" v-rnn label " РНН" format "x(12)" skip
  v-bic label 'БанкО' format  "x(12)"  help "F2 - Поиск" validate(can-find(ptpcln where ptpcln.bank = v-ourbank and ptpcln.cif = v-cif and ptpcln.bic = v-bic no-lock),'Не найдены реквизиты задолжника!')
  v-sbname label 'Наименование'  format "x(40)" skip
  v-iik label 'ИИК' format "x(20)" skip
  v-dt label "Дата ПТП" format "99/99/9999"
with centered side-label width 95 row 5 title "ПАРАМЕТРЫ ПТП" frame f-rst.

v-ourbank = comm-txb().
v-ptpnum = 0.
v-ptpcln = 0.
v-ptpreg = 0.
v-select = 0.

define query qt for t-ptpcln.
define button bsave label "Сохранить". /*для реквизитов просрочника*/

define browse bt query qt
displ t-ptpcln.rnn label "РНН" format "x(12)"
      t-ptpcln.name label "ФИО" format "x(40)"
      t-ptpcln.bic label "БанкО" format "x(12)" 
      t-ptpcln.iik label "Счет" format "x(20)" 
      with 30 down overlay no-label no-box.

define frame ft bt  help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl-D>-Удалить, <F4>-Выход" skip " " bsave 
 with width 110 row 3 overlay no-label title "Ввод реквизитов задолжника".

 
form 
  skip(1)
  v-cif label "Клиент" format "x(6)" help "F2 - Поиск" validate(can-find(cif where cif.cif = v-cif no-lock),'Клиент не найден!')
  v-name label "ФИО" format "x(50)" skip
  v-rnn label "РНН" format "x(12)" skip
  v-cbankl label "БанкО" format "x(9)" validate(can-find(bankl where bankl.bank = v-cbankl no-lock),'Банк не найден!') skip
  v-iik label "Счет" format "x(20)" validate( trim(v-iik) <> '' ,'Введите счет!') skip
with centered side-label row 5 title "РЕКВИЗИТЫ ЗАДОЛЖНИКА" frame f-ptpcln.

define query qtptp for t-ptp.
define button bsave1 label "Сохранить". /*для ПТП*/
def button bprint label "Печатать".
define browse btptp query qtptp
displ t-ptp.ptp label "№ ПТП" format "99999"
      t-ptp.rnn label "РНН" format "x(12)"
      t-ptp.name label "ФИО" format "x(20)"
      t-ptp.bic label "БанкО" format "x(12)" 
      t-ptp.iik label "Счет" format "x(10)" 
      t-ptp.sum label "Сумма" format ">>>,>>>,>>>,>>>9.99" 
      t-ptp.rstnum label "Реестр" format "99999"
      t-ptp.date label "Дата" format "99/99/9999"
      t-ptp.sts label "Стс" format "9"
       with 30 down overlay no-label no-box. 

define frame ftptp btptp  help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl-D>-Удалить, <F4>-Выход" skip " " bsave1 " " bprint
 with width 115 row 3 overlay no-label title "Ввод ПТП". 


def button brst label "Сформировать реестр ".
/*define button bexit label "Выход".*/ /*для реестра*/
define query qtrst for t-ptp.
define browse btrst query qtrst
displ t-ptp.ptp label "№ ПТП" format "99999"
      t-ptp.rnn label "РНН" format "x(12)"
      t-ptp.name label "ФИО" format "x(20)"
      t-ptp.bic label "БанкО" format "x(12)" 
      t-ptp.iik label "Счет" format "x(10)" 
      t-ptp.sum label "Сумма" format ">>>,>>>,>>>,>>>9.99" 
      t-ptp.rstnum label "Реестр" format "99999"
      t-ptp.date label "Дата" format "99/99/9999"
      t-ptp.sts label "Стс" format "9"
       with 30 down overlay no-label no-box. 


define frame ftrst btrst  help "<F4>-Выход" skip " "  brst 
 with width 115 row 3 overlay no-label title "Формирование реестра".             
 
run sel2 (" Формирование ПТП ", " 1. Ввод реквизитов задолжника | 2. Сформировать ПТП | 3. Сформировать реестр| ВЫХОД ", output v-select).
if v-select = 0 then return.

on "return" of bt in frame ft do: 
   find current t-ptpcln no-lock no-error.
   if not avail t-ptpcln then return.
   if t-ptpcln.cif <> '' then v-new = no.
   assign v-cif = t-ptpcln.cif
          v-name = t-ptpcln.name
          v-rnn = t-ptpcln.rnn
          v-cbankl = t-ptpcln.bic
          v-iik = t-ptpcln.iik.
   display v-cif v-name v-rnn v-cbankl v-iik with frame f-ptpcln. 
   if v-new then do:
      repeat on endkey undo, return:
          assign v-cif = '' v-rnn = '' v-name = ''.
          display v-name v-rnn with frame f-ptpcln.
          
          update v-cif with frame f-ptpcln.

          find first cif where cif.cif = v-cif no-lock no-error.
          if avail cif then assign v-name = cif.name v-rnn = cif.jss.  
          display v-name v-rnn with frame f-ptpcln.
          
          find first lon where lon.cif = v-cif and lon.sts <> 'c' no-lock no-error.
          if not avail lon then  message 'У клиента нет кредита!' view-as alert-box.
          else do:
              run lndaysprf(lon.lon,g-today, yes, output v-days_od, output v-days_prc).
              if v-days_od = 0 and v-days_prc = 0 then message 'У клиента нет просрочки по кредиту!' view-as alert-box.
              else leave. 
          end.  
             
      end.
   end.
   update v-cbankl v-iik with frame f-ptpcln.

   find current t-ptpcln exclusive-lock.
   assign t-ptpcln.bic = v-cbankl
          t-ptpcln.iik = v-iik.  
   if v-new then assign t-ptpcln.cif = v-cif t-ptpcln.name = v-name t-ptpcln.rnn = v-rnn.         
   open query qt for each t-ptpcln no-lock.
   find first t-ptpcln no-lock no-error.
   if avail t-ptpcln then bt:refresh().       
end.

on "insert-mode" of bt in frame ft do:
    find first pksysc where pksysc.sysc = 'ptpcln' no-lock no-error.
    if avail pksysc then do:
       v-ptpcln = pksysc.inval + 1.    
/*       find current pksysc exclusive-lock.
       pksysc.inval = v-ptpcln.  
       find current pksysc no-lock.*/
    end.  
          
    create t-ptpcln.
    assign t-ptpcln.ptpcln = v-ptpcln
           t-ptpcln.bank = v-ourbank
           t-ptpcln.rwho = g-ofc
           t-ptpcln.rdt = g-today.

    bt:set-repositioned-row(bt:focused-row, "always").
    v-rid = rowid(t-ptpcln).
    open query qt for each t-ptpcln no-lock.
    reposition qt to rowid v-rid no-error.
    find first t-ptpcln no-lock no-error.
    if avail t-ptpcln then bt:refresh().      
    
    v-new = yes.
    
    apply "return" to bt in frame ft.
    find first t-ptpcln where rowid(t-ptpcln) = v-rid no-lock.
    if t-ptpcln.cif = '' then do:
      find current t-ptpcln exclusive-lock.
      delete t-ptpcln.
    end.  
    else do:
      find current pksysc exclusive-lock.
      pksysc.inval = v-ptpcln.  
      find current pksysc no-lock.    
    end.
    
end.

on "delete-line" of bt in frame ft do:
    MESSAGE skip " Удалить запись?" skip(1)
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO 
    TITLE "РЕКВИЗИТЫ ЗАДОЛЖНИКА" UPDATE v-choice.
    if v-choice then do:
        bt:set-repositioned-row(bt:focused-row, "always").
        find current t-ptpcln exclusive-lock.
        create t-delptpcln.
        assign t-delptpcln.ptpcln = t-ptpcln.ptpcln
        t-delptpcln.cif = t-ptpcln.cif
        t-delptpcln.bank = t-ptpcln.bank.
        
        delete t-ptpcln.
        open query qt for each t-ptpcln no-lock.
        find first t-ptpcln no-lock no-error.
        if avail t-ptpcln then bt:refresh().
    end.
end.

on choose of bsave in frame ft do:
   i = 0.
   find first t-ptpcln where t-ptpcln.bank = v-ourbank no-lock no-error.
   if avail t-ptpcln then do:
       for each t-ptpcln where t-ptpcln.bank = v-ourbank no-lock:
         find first ptpcln where ptpcln.ptpcln = t-ptpcln.ptpcln exclusive-lock no-error.
         if not avail ptpcln then create ptpcln. 
         buffer-copy t-ptpcln except t-ptpcln.name t-ptpcln.rnn to ptpcln.
       end.
       i = i + 1.
   end.
   find first t-delptpcln where t-delptpcln.bank = v-ourbank no-lock no-error. 
   
   if avail t-delptpcln then do:
       for each t-delptpcln where t-delptpcln.bank = v-ourbank no-lock:
         find first ptpcln where ptpcln.ptpcln = t-delptpcln.ptpcln exclusive-lock no-error.
         if avail ptpcln then do:
            delete ptpcln.
         end.   
       end.
      i = i + 1. 
   end.
   if i > 0 then  message " Данные сохранены " view-as alert-box information.
   else message " Данные для сохранения отсутсвуют " view-as alert-box information.    
end.

/*******************/

def var v-selbic as integer no-undo.
def var v-selbicch as char no-undo.
on help of v-bic in frame f-ptp do:
   v-selbicch = ''.
   for each ptpcln where ptpcln.bank = v-ourbank and ptpcln.cif = v-cif no-lock:
     if v-selbicch <> '' then v-selbicch = v-selbicch + '|'.
     v-selbicch = v-selbicch + ptpcln.bic + ' ' + ptpcln.iik.
   end.
   
   run sel2 (" БИК Банка Отправителя ", v-selbicch, output v-selbic).
   if v-selbic = 0 then return.
   else do:
      v-bic = entry(1,entry(v-selbic, v-selbicch, '|'),' ').
      v-iik = entry(2,entry(v-selbic, v-selbicch, '|'),' ').
      find first bankl where bankl.bank = v-bic no-lock no-error.
      if avail bankl then v-sbname = bankl.name.
      display v-bic v-iik v-sbname with frame f-ptp.
   end.  

end.
on help of v-bic in frame f-rst do:
   v-selbicch = ''.
   for each ptpcln where ptpcln.bank = v-ourbank and ptpcln.cif = v-cif no-lock:
     if v-selbicch <> '' then v-selbicch = v-selbicch + '|'.
     v-selbicch = v-selbicch + ptpcln.bic + ' ' + ptpcln.iik.
   end.
   
   run sel2 (" БИК Банка Отправителя ", v-selbicch, output v-selbic).
   if v-selbic = 0 then return.
   else do:
      v-bic = entry(1,entry(v-selbic, v-selbicch, '|'),' ').
      v-iik = entry(2,entry(v-selbic, v-selbicch, '|'),' ').
      find first bankl where bankl.bank = v-bic no-lock no-error.
      if avail bankl then v-sbname = bankl.name.
      display v-bic v-iik v-sbname with frame f-rst.
   end.  
end.

on "return" of v-ptprem in frame f-ptp do: 
   apply "go" to v-ptprem in frame f-ptp.
end.


on "return" of btptp in frame ftptp do: 
   
   find current t-ptp no-lock no-error.
   if not avail t-ptp then return.
    
   if t-ptp.cif <> '' then v-newptp = no.
   
   assign v-cif = t-ptp.cif
          v-name = t-ptp.name
          v-rnn = t-ptp.rnn
          v-ptpnum = t-ptp.ptp
          v-bic = t-ptp.bic
          v-sbname =  t-ptp.sbname  
          v-iik = t-ptp.iik
          v-rbank = t-ptp.rbank
          v-rbiik = t-ptp.rbiik
          v-rbrnn = t-ptp.rbrnn
          v-kod = t-ptp.kod
          v-kbe = t-ptp.kbe
          v-knp = t-ptp.knp
          
          v-ptpsum = t-ptp.sum
          v-rstnum = t-ptp.rstnum 
          v-sts = t-ptp.sts
          v-stsrem = t-ptp.stsrem
          v-ptprem = t-ptp.ptprem
          v-ptpdt = t-ptp.date.
   
   if v-newptp then do:
      assign v-kod = 19
             v-kbe = 14
             v-knp = 429.
   end.      
   find first bankl where bankl.bank = v-ourbank no-lock no-error.
   if avail bankl then v-rbname = bankl.name.
   
   if v-newptp then do:
      find first txb where txb.consolid and txb.bank = v-ourbank no-lock no-error.
      if not avail txb then next. 
     
      find first sysc where sysc.sysc = 'ptpiik' no-lock no-error.
      
      if not avail sysc then next.      
      assign v-rbank = txb.mfo
             v-rbiik = sysc.chval
             v-rbrnn = entry(1,txb.params).
   end.       
   
   display v-ptpnum v-cif v-name v-rnn v-bic v-sbname v-iik v-rbank v-rbname v-rbrnn v-rbiik v-kod v-kbe v-knp v-rstnum v-ptpdt v-ptpsum v-sts v-stsrem v-ptprem with frame f-ptp.
   
   if v-newptp then do:
      
      update v-ptpnum with frame f-ptp.
      repeat on endkey undo, return:
          assign v-cif = '' v-rnn = '' v-name = ''.
          display v-name v-rnn with frame f-ptp.
          
          update v-cif with frame f-ptp.

          find first cif where cif.cif = v-cif no-lock no-error.
          if avail cif then assign v-name = cif.name v-rnn = cif.jss.  
          display v-name v-rnn with frame f-ptp.
          
          find first lon where lon.cif = v-cif and lon.sts <> 'c' no-lock no-error.
          if not avail lon then  message 'У клиента нет кредита!' view-as alert-box.
          else do:
              run lndaysprf(lon.lon,g-today, yes, output v-days_od, output v-days_prc).
              if v-days_od = 0 and v-days_prc = 0 then message 'У клиента нет просрочки по кредиту!' view-as alert-box.
              else do:
                 find loncon where loncon.lon = lon.lon no-lock no-error. 
                 v-ptprem = ''.
                 if avail loncon then v-ptprem = loncon.lcnt + ' от ' + string(lon.rdt,'99/99/9999') + ' г.'. 
                 leave. 
              end.  
          end.         
      end. /*repeat*/
   end.
   if v-newptp or v-rstnum = 0 then do:      
      update v-bic with frame f-ptp.
      find first bankl where bankl.bank = v-bic no-lock no-error.
      if avail bankl then v-sbname = bankl.name.
      display v-bic v-iik v-sbname with frame f-ptp.
          
      update v-ptpdt v-ptpsum with frame f-ptp.
      if v-newptp then v-ptprem = "Безакцептное списание по просроченному платежу в сумме " + replace(trim(string(v-ptpsum, '>>>>>>>>>>>>9.99')),'.',',') + " тенге согласно Договору о предоставлении микрокредита № " + v-ptprem .
      update v-ptprem with frame f-ptp.
   end.
   else do:   
     v-stsold = v-sts.
     update v-sts with frame f-ptp.
     if v-sts > 0 then update v-stsrem  with frame f-ptp.     
        
   end.    
   
   find current t-ptp exclusive-lock.
   assign t-ptp.ptp = v-ptpnum
          t-ptp.bic = v-bic 
          t-ptp.sbname = v-sbname
          t-ptp.iik = v-iik 
          t-ptp.rbank = v-rbank
          t-ptp.rbiik = v-rbiik
          t-ptp.rbrnn = v-rbrnn 
          t-ptp.kod = v-kod 
          t-ptp.kbe = v-kbe
          t-ptp.knp = v-knp
          t-ptp.sum = v-ptpsum
          t-ptp.rstnum  = v-rstnum
          t-ptp.sts = v-sts
          t-ptp.stsrem = v-stsrem
          t-ptp.ptprem = v-ptprem
          t-ptp.date = v-ptpdt.       
   
   if v-stsold <> v-sts then assign t-ptp.stswho = g-ofc t-ptp.stsdt = g-today.       
          
   if v-newptp then assign t-ptp.cif = v-cif t-ptp.name = v-name t-ptp.rnn = v-rnn.         
   open query qtptp for each t-ptp no-lock.
   find first t-ptp no-lock no-error.
   if avail t-ptp then btptp:refresh().       
end.

on "insert-mode" of btptp in frame ftptp do:
    find first pksysc where pksysc.sysc = 'ptpnum' no-lock no-error.
    if avail pksysc then do:
       v-ptpnum = pksysc.inval + 1.    
      /* find current pksysc exclusive-lock.
       pksysc.inval = v-ptpnum.  
       find current pksysc no-lock.*/
    end.  
          
    create t-ptp.
    assign t-ptp.ptp = v-ptpnum
           t-ptp.bank = v-ourbank
           t-ptp.rwho = g-ofc
           t-ptp.rdt = g-today
           t-ptp.date = g-today.
    
    btptp:set-repositioned-row(btptp:focused-row, "always").
    v-ridptp = rowid(t-ptp).
    open query qtptp for each t-ptp no-lock.
    reposition qtptp to rowid v-ridptp no-error.
    find first t-ptp no-lock no-error.
    if avail t-ptp then btptp:refresh().      
    
    v-newptp = yes.
    v-cif = ''.
    apply "return" to btptp in frame ftptp.
    find first t-ptp where rowid(t-ptp) = v-ridptp no-lock.
    if t-ptp.cif = '' then do:
      find current t-ptp exclusive-lock.
      delete t-ptp.
    end.  
    else do:
      find current pksysc exclusive-lock.
      pksysc.inval = v-ptpnum.  
      find current pksysc no-lock.    
    end.    
end.

on "delete-line" of btptp in frame ftptp do:
    v-choice = no.
    MESSAGE skip " Удалить запись?" skip(1)
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO 
    TITLE "ПТП" UPDATE v-choice.
    if v-choice then do:
        btptp:set-repositioned-row(btptp:focused-row, "always").
        find current t-ptp exclusive-lock.
        create t-delptp.
        assign t-delptp.ptp = t-ptp.ptp
        t-delptp.cif = t-ptp.cif
        t-delptp.bank = t-ptp.bank.
        delete t-ptp.
        open query qtptp for each t-ptp no-lock.
        find first t-ptp no-lock no-error.
        if avail t-ptp then btptp:refresh().
    end.
end.

on choose of bsave1 in frame ftptp do:
   i = 0.
   find first t-ptp where t-ptp.bank = v-ourbank no-lock no-error.
   if avail t-ptp then do:
       for each t-ptp where t-ptp.bank = v-ourbank no-lock:
         find first ptp where ptp.ptp = t-ptp.ptp exclusive-lock no-error.
         if not avail ptp then create ptp. 
         buffer-copy t-ptp to ptp.
       end.
       i = i + 1.
   end.
   find first t-delptp where t-delptp.bank = v-ourbank no-lock no-error. 
   
   if avail t-delptp then do:
       for each t-delptp where t-delptp.bank = v-ourbank no-lock:
         find first ptp where ptp.ptp = t-delptp.ptp exclusive-lock no-error.
         if avail ptp then do:
            delete ptp.
         end.   
       end.
      i = i + 1. 
   end.
   if i > 0 then  message " Данные сохранены " view-as alert-box information.
   else message " Данные для сохранения отсутсвуют " view-as alert-box information.    
end.
/*******************/
def var v-chnewtrs as logical no-undo.
on 'choose' of brst in frame ftrst do:
   find first t-ptp where t-ptp.bank = v-ourbank no-lock no-error.
   if not avail t-ptp then do:
     message "Нет ПТП для формирования реестра!" view-as alert-box title "ВНИМАНИЕ".
     return.
   end.
   v-cif = ''.
   v-dt = ?.
   v-name = ''. 
   v-rnn  = ''.
   v-bic  = ''.
   v-sbname  = ''.
   v-iik = ''.
   display v-cif v-dt v-name v-rnn v-bic v-sbname v-iik with frame f-rst.
   
   v-chnewtrs = no.
   MESSAGE skip " Создать новый реестр?" skip(1)
   VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO 
   TITLE "Реестр" UPDATE v-chnewtrs.

   find first pksysc where pksysc.sysc = 'ptprst' no-lock no-error.
   if avail pksysc then do:
     if v-chnewtrs then v-ptpreg = pksysc.inval + 1.    
 /*        find current pksysc exclusive-lock.
         pksysc.inval = v-ptpreg.  
         find current pksysc no-lock.*/
      else v-ptpreg = pksysc.inval.
   end.  
   
   
   repeat on endkey undo, return:
      update v-ptpreg with frame f-rst.
      find first ptp where ptp.bank = v-ourbank and ptp.rstnum = v-ptpreg no-lock no-error.
      if avail ptp and v-chnewtrs then message "Реестр с таким номером уже существует!" view-as alert-box.
      if not avail ptp and not v-chnewtrs then message "Не найден реестр с таким номером!" view-as alert-box. 
      if (avail ptp and not v-chnewtrs) or (not avail ptp and v-chnewtrs) then leave.   
   end.

   if not v-chnewtrs then do:
     find first ptp where ptp.rstnum = v-ptpreg no-lock no-error.
     v-cif = ptp.cif.
   end.  
   else update v-cif with frame f-rst.
    
   
   find first cif where cif.cif = v-cif no-lock no-error.
   if avail cif then assign v-name  = cif.name v-rnn = cif.jss.
   display v-name v-rnn with frame f-rst.
   if not v-chnewtrs then do:
      v-bic = ptp.bic.
      find first bankl where bankl.bank =  ptp.bic no-lock no-error.
      if avail bankl then v-sbname = bankl.name.
      v-iik = ptp.iik.
      v-dt = ptp.date.
   end.
   else do:
     update v-bic with frame f-rst.
     find first ptpcln where ptpcln.bank = v-ourbank and ptpcln.cif = v-cif and ptpcln.bic = v-bic no-lock no-error.
     if avail ptpcln then do:
        find first bankl where bankl.bank =  ptpcln.bic no-lock no-error.
        if avail bankl then v-sbname = bankl.name.
        v-iik = ptpcln.iik. 
     end.
     update v-dt with frame f-rst.
   end.
   display v-ptpreg v-cif v-name v-rnn v-bic v-sbname v-iik v-dt with frame f-rst.
   if v-chnewtrs then do:
      find first t-ptp where t-ptp.bank = v-ourbank and t-ptp.cif = v-cif and t-ptp.bic = v-bic and t-ptp.iik = v-iik and t-ptp.date = v-dt and t-ptp.sts = 0 and t-ptp.rstnum = 0 no-lock no-error.
      if not avail t-ptp then message "Не найдены ПТП, соответствующие введенным параметрам.~n Или реестр на данные ПТП сформирован ранее!" view-as alert-box title 'ВНИМАНИЕ'.
      else do: 
          for each t-ptp where t-ptp.bank = v-ourbank and t-ptp.cif = v-cif and t-ptp.bic = v-bic and t-ptp.iik = v-iik and t-ptp.date = v-dt and t-ptp.sts = 0 and t-ptp.rstnum = 0 exclusive-lock:
            t-ptp.rstnum = v-ptpreg.
          end.
          
          for each ptp where ptp.bank = v-ourbank and ptp.cif = v-cif and ptp.bic = v-bic and ptp.iik = v-iik and ptp.date = v-dt and ptp.sts = 0 and ptp.rstnum = 0 exclusive-lock:
            assign ptp.rstnum = v-ptpreg
                   ptp.rstdt = g-today
                   ptp.rstwho = g-ofc. 
          end.  
          
          open query qtrst for each t-ptp no-lock.
          find first t-ptp no-lock no-error.
          if avail t-ptp then btrst:refresh().
          
          find current pksysc exclusive-lock.
          pksysc.inval = v-ptpreg.  
          find current pksysc no-lock.
      end.
   end.
   find first bankl where bankl.bank = v-ourbank no-lock no-error.
   if avail bankl then v-rbname = bankl.name.

   j = 0.  
   v-totsum = 0.
   v-ptpch = ''.
   for each t-ptp where t-ptp.date = v-dt and t-ptp.rstnum = v-ptpreg no-lock:
      j = j + 1.
      v-totsum = v-totsum + t-ptp.sum. 
      v-ptpch = v-ptpch + "<td style=""border-style:solid; border-color:black;"">" + string(j)  + "</td><td style=""border-style:solid; border-color:black"">" + trim(string(t-ptp.ptp,'>>>>>99999')) + "</td><td style=""border-style:solid; border-color:black"">" + string(t-ptp.date, "99/99/9999") + "</td><td style="" border-style:solid; border-color:black; "">" + replace(string(t-ptp.sum, ">>>>>>>>>>>9.99"), ".", ",") + "</td>".
   end.

   
   find first t-ptp where t-ptp.date = v-dt and t-ptp.rstnum = v-ptpreg no-lock no-error.
   if not avail t-ptp then next.  
   v-dtch = string(day(t-ptp.date),'99') + ' ' + entry(month(t-ptp.date),v-month) + ' ' + string(year(t-ptp.date),'9999') + ' года.'.      
      
   
   v-chif = ''.   
   if v-ourbank = 'TXB00' then v-chif = 'Котуков В. А.'.
   else v-chif = get-sysc-cha ("DKPODP").
   
   v-mainbk = get-sysc-cha ("MAINBK").
   
   v-infile = '/data/docs/ptprst.htm'.
   v-ofile = 'ptprst.xls'.   
   
   output stream v-out to value(v-ofile).
  /********/
 
  input from value(v-infile).
  repeat:
      import unformatted v-str.
      v-str = trim(v-str).
        
      repeat:
          if v-str matches "*\{\&v-ptpreg\}*" then do:
              v-str = replace (v-str, "\{\&v-ptpreg\}", trim(string(v-ptpreg,'>>>99999'))).
              next.
          end.
          
          if v-str matches "*\{\&v-date\}*" then do:
              v-str = replace (v-str, "\{\&v-date\}",v-dtch ).
              next.
          end.
          
          if v-str matches "*\{\&v-count\}*" then do:
              v-str = replace (v-str, "\{\&v-count\}", string(j) ).
              next.
          end.
          
          if v-str matches "*\{\&v-filial\}*" then do:
              v-str = replace (v-str, "\{\&v-filial\}", v-rbname + ' РНН ' + t-ptp.rbrnn).
              next.
          end.
            
          if v-str matches "*\{\&v-rbname\}*" then do:
              v-str = replace (v-str, "\{\&v-rbname\}", v-rbname).
              next.
          end.
          
          if v-str matches "*\{\&v-rbrnn\}*" then do:
              v-str = replace (v-str, "\{\&v-rbrnn\}", t-ptp.rbrnn).
              next.
          end.
          
          if v-str matches "*\{\&v-riik\}*" then do:
              v-str = replace (v-str, "\{\&v-riik\}", t-ptp.rbiik).
              next.
          end.

          if v-str matches "*\{\&v-rbic\}*" then do:
              v-str = replace (v-str, "\{\&v-rbic\}", t-ptp.rbank).
              next.
          end.

          if v-str matches "*\{\&v-ptp\}*" then do:
              v-str = replace (v-str, "\{\&v-ptp\}", v-ptpch).
              next.
          end.

      
          if v-str matches "*\{\&v-totsum\}*" then do:
              v-str = replace (v-str, "\{\&v-totsum\}", replace(trim(string(v-totsum,'>>>>>>>>>>>>>9.99')),'.',',')).
              next.
          end.
 
        
          if v-str matches "*\{\&v-chif\}*" then do:
              v-str = replace (v-str, "\{\&v-chif\}", v-chif).
              next.
          end.

          if v-str matches "*\{\&v-mainbk\}*" then do:
              v-str = replace (v-str, "\{\&v-mainbk\}", v-mainbk).
              next.
          end.
         
          leave.
      end. /* repeat */
        
      put stream v-out unformatted v-str skip.
  end. /* repeat */
  input close.
    /********/  
  
  output stream v-out close.
  output stream v-out to value(v-ofile) append.
  output stream v-out close.
  unix silent value("cptwin " + v-ofile + " excel").
  unix silent value("rm -r " + v-ofile).
   
end.

on 'choose' of bprint in frame ftptp do:
   find current t-ptp no-lock no-error.
   if not avail t-ptp then do:
      message "Нет ПТП для печати!" view-as alert-box.
      return.
   end.
   v-dtch = string(day(t-ptp.date),'99') + ' ' + entry(month(t-ptp.date),v-month) + ' ' + string(year(t-ptp.date),'9999') + ' года.'.      
   
   v-sumch = replace(trim(string(t-ptp.sum, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", " ").
   run Sm-vrd (t-ptp.sum, output v-sum1).
   run Sm-vrd (deci(entry(2,v-sumch,'.')), output v-sum2).
   run sm-wrdcrc (substr(v-sumch, 1, length(v-sumch) - 3), substr(v-sumch, length(v-sumch) - 1), 1, output v-crc1, output v-crc2).
   /*v-sumwrd = v-sum1 + " " + v-crc1 + " " +  v-sum2 + " " + v-crc2.*/
   v-sumwrd = v-sum1 + " " + v-crc1 + " " +  entry(2,v-sumch,'.') + " " + v-crc2.
  
   find first bankl where bankl.bank = v-ourbank no-lock no-error.
   if avail bankl then v-rbname = bankl.name.          
   
   v-chif = ''.
   if v-ourbank = 'TXB00' then v-chif = 'Котуков В. А.'.
   else v-chif = get-sysc-cha ("DKPODP").
   
   v-mainbk = get-sysc-cha ("MAINBK").
   v-infile = '/data/docs/ptp.htm'.
   v-ofile = 'ptp.xls'.   
   output stream v-out to value(v-ofile).
  /********/
 
  input from value(v-infile).
  repeat:
      import unformatted v-str.
      v-str = trim(v-str).
        
      repeat:
          if v-str matches "*\{\&v-ptpnum\}*" then do:
              v-str = replace (v-str, "\{\&v-ptpnum\}", trim(string(t-ptp.ptp,'>>>99999'))).
              next.
          end.
          
          if v-str matches "*\{\&v-date\}*" then do:
              v-str = replace (v-str, "\{\&v-date\}",v-dtch ).
              next.
          end.

          if v-str matches "*\{\&v-clname\}*" then do:
              v-str = replace (v-str, "\{\&v-clname\}", t-ptp.name).
              next.
          end.

          if v-str matches "*\{\&v-rnn\}*" then do:
              v-str = replace (v-str, "\{\&v-rnn\}", t-ptp.rnn).
              next.
          end.

          if v-str matches "*\{\&v-iik\}*" then do:
              v-str = replace (v-str, "\{\&v-iik\}", t-ptp.iik).
              next.
          end.

          if v-str matches "*\{\&v-sbname\}*" then do:
              v-str = replace (v-str, "\{\&v-sbname\}", t-ptp.sbname).
              next.
          end.

          if v-str matches "*\{\&v-sbic\}*" then do:
              v-str = replace (v-str, "\{\&v-sbic\}", t-ptp.bic).
              next.
          end.
            
          if v-str matches "*\{\&v-rbname\}*" then do:
              v-str = replace (v-str, "\{\&v-rbname\}", v-rbname).
              next.
          end.
          
          if v-str matches "*\{\&v-rbrnn\}*" then do:
              v-str = replace (v-str, "\{\&v-rbrnn\}", t-ptp.rbrnn).
              next.
          end.
          
          if v-str matches "*\{\&v-riik\}*" then do:
              v-str = replace (v-str, "\{\&v-riik\}", t-ptp.rbiik).
              next.
          end.

          if v-str matches "*\{\&v-rbic\}*" then do:
              v-str = replace (v-str, "\{\&v-rbic\}", t-ptp.rbank).
              next.
          end.

          if v-str matches "*\{\&v-kod\}*" then do:
              v-str = replace (v-str, "\{\&v-kod\}", string(t-ptp.kod,'99')).
              next.
          end.

          if v-str matches "*\{\&v-kbe\}*" then do:
              v-str = replace (v-str, "\{\&v-kbe\}", string(t-ptp.kbe,'99')).
              next.
          end.


          if v-str matches "*\{\&v-knp\}*" then do:
              v-str = replace (v-str, "\{\&v-knp\}", string(t-ptp.knp,'999')).
              next.
          end.

          if v-str matches "*\{\&v-sum\}*" then do:
              v-str = replace (v-str, "\{\&v-sum\}", replace(trim(string(t-ptp.sum,'>>>>>>>>>>>>>9.99')),'.',',')).
              next.
          end.
 
          if v-str matches "*\{\&v-sumwrd\}*" then do:
              v-str = replace (v-str, "\{\&v-sumwrd\}", v-sumwrd).
              next.
          end.

          if v-str matches "*\{\&v-rem\}*" then do:
              v-str = replace (v-str, "\{\&v-rem\}", t-ptp.ptprem).
              next.
          end.

          if v-str matches "*\{\&v-chif\}*" then do:
              v-str = replace (v-str, "\{\&v-chif\}", v-chif).
              next.
          end.

          if v-str matches "*\{\&v-mainbk\}*" then do:
              v-str = replace (v-str, "\{\&v-mainbk\}", v-mainbk).
              next.
          end.
         
          leave.
      end. /* repeat */
        
      put stream v-out unformatted v-str skip.
  end. /* repeat */
  input close.
    /********/  
  
  output stream v-out close.
  output stream v-out to value(v-ofile) append.
  output stream v-out close.
  unix silent value("cptwin " + v-ofile + " excel").
  unix silent value("rm -r " + v-ofile).
end.


case v-select:
    when 1 then do:
        empty temp-table t-ptpcln.
        empty temp-table t-delptpcln.

        for each ptpcln where ptpcln.bank = v-ourbank no-lock:
          find first cif where cif.cif = ptpcln.cif no-lock no-error.
          if not avail cif then next.

          find first bankl where bankl.bank = ptpcln.bic no-lock no-error.
          if not avail bankl then next.

          create t-ptpcln.
          buffer-copy ptpcln to t-ptpcln.
          assign t-ptpcln.name = cif.name
                 t-ptpcln.rnn = cif.jss.
          
        end.
        
        open query qt for each t-ptpcln no-lock.
        enable bt bsave with frame ft.
    
        wait-for choose of bsave or window-close of current-window.
        pause 0.

    end.
    when 2 or when 3 then do:
        empty temp-table t-ptp.
        empty temp-table t-delptp.

        for each ptp where ptp.bank = v-ourbank no-lock:
          find first cif where cif.cif = ptp.cif no-lock no-error.
          if not avail cif then next.
          
          find first bankl where bankl.bank = ptp.bic no-lock no-error.
          if not avail bankl then next.
          find first txb where txb.consolid and txb.bank = v-ourbank no-lock no-error.
          if not avail txb then next. 
          find first sysc where sysc.sysc = 'ptpiik' no-lock no-error.
          if not avail sysc then next.
          find first arp where arp.arp = sysc.chval no-lock no-error.
          if not avail arp then next.
          
          create t-ptp.
          assign t-ptp.ptp = ptp.ptp
                 t-ptp.bank = v-ourbank
                 t-ptp.cif = ptp.cif
                 t-ptp.name = cif.name
                 t-ptp.rnn = cif.jss
                 t-ptp.bic = ptp.bic 
                 t-ptp.sbname = bankl.name
                 t-ptp.iik = ptp.iik
                 t-ptp.rbank = txb.mfo
                 t-ptp.date = v-ptpdt 
                 t-ptp.rbiik = sysc.chval
                 t-ptp.rbrnn = entry(1,txb.params)
                 t-ptp.kod = ptp.kod
                 t-ptp.kbe = ptp.kbe
                 t-ptp.knp = ptp.knp
                 t-ptp.date = ptp.date
                 t-ptp.sum = ptp.sum
                 t-ptp.rstnum = ptp.rstnum 
                 t-ptp.sts = ptp.sts
                 t-ptp.stsrem = ptp.stsrem
                 t-ptp.ptprem = ptp.ptprem.
        end.

        if v-select = 3 then do:
            open query qtrst for each t-ptp no-lock.
            enable all with frame ftrst.
            wait-for window-close of current-window.
        end.
        else do: 
            open query qtptp for each t-ptp no-lock.
            enable all with frame ftptp.
            wait-for choose of bsave1 or window-close of current-window.
        end.
 
        pause 0.
    end.
    when 4 then return.    
end.