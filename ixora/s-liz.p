/* s-liz.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

/*
   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/


&IF "{&OPSYS}" = "UNIX" &THEN
define input parameter p-rg as integer.
define shared variable s-lon like lon.lon.
define shared variable g-today as date.
define shared variable g-ofc   as char.
define shared variable rc   as integer.
&ENDIF
define variable kopa-s      as decimal decimals 10.
define variable ava-s       as decimal decimals 10.
define variable pirk-s      as decimal decimals 10.
define variable lizi-s      as decimal decimals 10.
define variable maks-s      as decimal decimals 10.
define variable s-maks      as decimal decimals 10.
define variable k-maks      as decimal decimals 10.
define variable p-maks      as decimal decimals 10.
define variable maks-pg     as decimal decimals 10.
define variable maks-pm     as decimal decimals 10.
define variable maks-pmn    as decimal decimals 10.
define variable maks-pd     as decimal decimals 10.
define variable dn          as integer.
define variable mn          as integer.
define variable ava-p       as decimal decimals 10 format ">>9.99".
define variable pirk-p      as decimal decimals 10.
define variable depo-mn     as integer.
define variable depo-s      as decimal decimals 10.
define variable atal-p      as decimal decimals 10.
define variable atal-s      as decimal decimals 10.
define variable form-s      as decimal decimals 10.
define variable sod1-p      as decimal decimals 10.
define variable sod2-p      as decimal decimals 10.
define variable sod3-p      as decimal decimals 10.
define variable lon-pvn     as decimal decimals 10.
define variable pvn-sum     as decimal decimals 10.
define variable sv-cost-pay as decimal decimals 10.
define variable sv-not-paied as decimal decimals 10.
define variable graph-type  as character.
define variable s1   as decimal.
define variable s2   as decimal.
define variable s3   as decimal.
define variable s4   as decimal.
define variable a    as decimal.
define variable b    as decimal.
define variable c    as decimal.
define variable d    as decimal.
define variable e    as decimal.
define variable q    as decimal.
define variable pk   as decimal.
define variable m1   as decimal.
define variable mk   as decimal.
define variable v-dt  as date.
define variable v-dt1 as date.
define variable v-dt2 as date.
define variable v-dt3 as date.
define variable v-pss as character.
define variable i    as integer.
define variable j    as integer.
define variable k    as integer.
define variable l    as integer.
define variable m    as integer.
define variable n    as integer.
define variable min-lon as character.
define variable max-lon as character.
define variable var     as character.
define variable v-key   as character.
define variable ja      as logical.
define variable c-dt    as character.
define variable new-graph as logical.
define variable new-obj   as logical.
define variable new-obj-rec as logical.

define variable period  as integer no-undo.

def var v-amt as decimal decimals 2 format ">>>,>>>,>>>,>>9.99-".
def var v-payment as decimal decimals 2.
def var v-pl as decimal decimals 2 format ">>>,>>>,>>>,>>9.99-".
def var v-pr as decimal decimals 2 format ">>>,>>>,>>>,>>9.99-".
def var v-pt as decimal decimals 2 format ">>>,>>>,>>>,>>9.99-".
def var v-sum as decimal decimals 2 format ">>>,>>>,>>>,>>9.99-".
def var v-bassum as decimal decimals 2 format ">>>,>>>,>>>,>>9.99-".
def var savePeriodSum as integer.
def var v-nm as int.
def var v-day as int.
def var tmpChar as character.

def var v-rate as dec decimals 2 format "999.99".
def var v-edit as log.

def var per-pay       as decimal decimals 10. /* periodical payment in month */
def var prc-mon       as decimal decimals 10.
def var payment0      as logi.                /* ir 0 maks–jums */
def var payment1      as logi.                /* ir % vai pamatsummas dzёЅ–na */
def var payment-depo  as logi.                /* ir g.deposita maks–jums */

define buffer falon1 for falon.

{ s-liz.i "NEW" }

def var v-ans as log.
def temp-table wf
    field nm as int format ">>9" column-label "Период времени"
    field rate as dec decimals 2 format "999.99" column-label "Ставка".

def temp-table Graph 
    field n             as int
    field month         as char format "x(6)"
    field pay-date      as date format "99/99/9999"
    field not-paied     as decimal decimals 10 format ">>>,>>>,>>9.99"
    field cost-pay      as decimal decimals 10 format ">>>,>>>,>>9.99"
    field prc-cost-pay  as decimal decimals 10 format "zz9.99"
    field prc-pay       as decimal decimals 10 format ">>>,>>>,>>9.99"
    field atalg-pay     as decimal decimals 10 format ">>>,>>>,>>9.99"    
    field pvn-pay       as decimal decimals 10 format ">>>,>>>,>>9.99"
    field tot-pay       as decimal decimals 10 format ">>>,>>>,>>9.99"    
    field rate          as decimal             format "zz9.99"
    field fx-cost-pay   as logical format "  X /"
    field fx-amt-pay    as logical format "  X /".

define var ch-rate           like Graph.rate no-undo.
define var ch-prc-cost-pay   like Graph.prc-cost-pay no-undo.
define var save-prc-cost-pay like Graph.prc-cost-pay no-undo.
define var ch-cost-pay       like Graph.cost-pay no-undo.
define var save-cost-pay     like Graph.cost-pay no-undo.
define var mn-total          as   integer no-undo.
define var mn-count          as   integer no-undo.

define var cmbPvnType    as character view-as combo-box inner-lines 3 format "x(15)".
define var cmbPeriodType as character view-as combo-box inner-lines 4 format "x(15)".
define var cmbProcType   as character view-as combo-box inner-lines 3 format "x(15)".
define var cmbCostType   as character view-as combo-box inner-lines 3 format "x(15)".
define var cmbAmtType    as character view-as combo-box inner-lines 3 format "x(15)".

def var cMessage   as char.
def var dMessage   as char.
def var eMessage   as char.
def var fMessage   as char.
def var gMessage   as char.

cMessage = "[ENTER]  -редакт.  [F1] -сохран.   [F4] -отмен.                                " + 
           "[1]-неоплаченная стоимость постоян./перемен. [2] - процент постоян./перемен.   ".
dMessage = "Выполнена транзакция. Вы не можете ввести сумму меньше ".
eMessage = "[CURSOR-DOWN] -помощь [TAB] -след.строка [F1] -сохранить [F4]-отмена".
fMessage = "[ENTER]  -редакт.  [F1] -сохран.   [F4] -отмена                             ".
gMessage = "[F2]  -помощь    [INSERT] -новый     [F1] -сохран.     [F4] -отмена         ".

&SCOPED-DEFINE cHelpString "F2 - помощь "
&SCOPED-DEFINE glFacifDisplay1 "cFacifFacif cFacifName cFacifAddr cFacifTel1 cFacifTel2 cFacifFax cFacifBanka cFacifKonts cFacifFanrur cFacifPvnMaks "
&SCOPED-DEFINE glFacifDisplayApd "cFacifFacifApd cFacifNameApd cFacifAddrApd "

/*------- DEFINE BUTTONS ----------*/
define button btnGraph    label "График".
define button btnObject   label "Объект".
define button btnAddInfo  label "Доп.информация".
define button btnNewGraph label "Нов.график".
define button btnOk       label "  Ok  "   auto-go.
define button btnCancel   label " Cancel " auto-endkey.
define button btnPrint    label " Печать ".

/*------- DFEINE FRAMES -----------*/
define frame frmBrwGraph.
define frame frmGraph.
define frame frmUpdPrcCost.

/*-------- DEFINE QUERY ------------------*/
def query qryGraph    for Graph.
def query qryTmp      for Graph.

&IF "{&OPSYS}" = "UNIX" &THEN

/*-------- DEFINE BROWSE ------------------*/
def browse brwGraph query qryGraph no-lock
    display month        column-label "Месяц"
            pay-date     column-label "Дата"
            rate         column-label "Дог.%"
            prc-cost-pay column-label "% выкупа"
            fx-amt-pay   column-label "Fix1" format " X /"
            fx-cost-pay  column-label "Fix2" format " X /"
            not-paied    column-label "Неоплачен.стоим."
            cost-pay     column-label "Платеж выкупа"            
            prc-pay      column-label "% платежа"
            atalg-pay    column-label "Опл. лизинг"
            pvn-pay      column-label "Налог"
            tot-pay      column-label "Опл.договора"
            
            with 11 down width 76 no-box .


/*-------- DEFINE FORMS ------------------*/   
form falon.falon      format "x(16)" label "Код объекта"
     falon.rez-dec[1] format ">>>,>>>,>>9.99" label "Цена предмета"
     falon.opnamt     format ">>>,>>>,>>9.99" label "Сумма лизинга"
     falon.obj        view-as fill-in size 30 by 1 format "x(300)" 
                      label "Описание"
     with down centered overlay scroll 1 width 80 row 5 title "Объект" 
     frame falon.

define rectangle rctLine graphic-edge size 78 by 1.
define rectangle rctLine1 like rctLine.

form ava-p    format ">9.99"          label "Аванса %........"
     ava-s    format ">>>,>>>,>>9.99" label "Аванса сумма...." at 43
     lon-pvn  format ">>9.99"         label "Налог. %........"
     pvn-sum  format ">>>,>>>,>>9.99" label "Налог. общ.сумма" at 43
     pirk-p   format ">9.99"          label "% выкупа........"
     pirk-s   format ">>>,>>>,>>9.99" label "Сумма выкупа...." at 43
     depo-mn  format "z9"             label "Гарант.период..."
     depo-s   format ">>>,>>>,>>9.99" label "Гарант.сумма...." at 43
     dn       format "zz9"            label "Продолжит.1 пер." skip
     atal-p   format ">9.99"          label "% оплаты лизинга"
     atal-s   format ">>>,>>>,>>9.99" label "Сумма опл.лизинг" at 43
     form-s   format ">>9.99"         label "Оформление......" skip
     sod1-p   format ">9.99"          label "Штраф за 1 проср" skip
     sod2-p   format ">9.99"          label "Штраф за 2 проср"
     btnGraph at 50 skip     
     sod3-p   format ">9.99"          label "Штраф за 3 проср"
     btnObject  at 50 skip
     btnAddInfo at 50 skip(3)
     btnOk at 30 space(5) btnCancel skip
     with side-label row 5 overlay centered title "Лизинг" width 80 
     frame d.

form "Продавец" at 35 skip
     cFacifFacif format "x(6)"          label "Код.........."  
                 help {&cHelpString} skip
     cFacifName  format "x(50)"         label "Продавец....." 
                      help {&cHelpString} skip
     cFacifAddr  format "x(50)"         label "Адрес........"
                 help {&cHelpString} skip
     cFacifTel1  format "(xxx)xxx-xxxx" label "Телефон......" 
                 help {&cHelpString} ","
     cFacifTel2  format "(xxx)xxx-xxxx" no-label
                 help {&cHelpString}
     cFacifFax   format "(xxx)xxx-xxxx" label "Факс......." 
                 help {&cHelpString} skip
     cFacifBanka format "x(29)"         label "Банк........." 
                      help {&cHelpString}
     cFacifKonts format "x(15)"         label "Счет......"
                 help {&cHelpString} skip
     cFacifFanrur  format "x(18)"       label "Рег.удостовер"
                      help {&cHelpString}
     cFacifPvnMaks format "x(15)"       label "Регистрацион.Nr"
                 help {&cHelpString} skip
     rctLine skip
     "Страховая компания" at 30 skip
     
     cFacifFacifApd format "x(6)"        label "Код..........." 
                      help {&cHelpString} skip
     cFacifNameApd  format "x(50)"       label "Страх.компания"
                 help {&cHelpString} skip
     cFacifAddrApd  format "x(50)"       label "Адрес........."
                 help {&cHelpString} skip(1)
     btnOk at 30 space(5) btnCancel skip
     with side-label row 5 overlay centered title "Доп.информация" 
     width 80 frame frmAddInfo.     
&ENDIF

form 
   cmbPvnType    label "Налог                 " skip
   cmbPeriodType label "Период платежа        " skip
   cmbProcType   label "Тип % ставки          " skip
   cmbCostType   label "Сумма платежа         " skip
   cmbAmtType    label "Неоплач.стоимость пред" skip(1)
   
   btnOk at 20 space(3) btnCancel
   with side-label row 6 overlay centered title "График" width 60 
   frame frmGraph.

&IF "{&OPSYS}" = "UNIX" &THEN
   
form 
   brwGraph skip(1)
   btnOk at 24 space(3) btnCancel space(3) btnPrint
   with side-label row 5 overlay centered width 80 frame frmBrwGraph.

form
   Graph.month     label "Месяц                "  skip
   Graph.pay-date  label "Дата платежа         "  skip
   Graph.not-paied label "Неоплач.стоимость пр."  skip
   Graph.rate      label "Процент              "  skip
   Graph.cost-pay  label "Оплата основной стоим"  skip(1)
   btnOk at 13 space(3) btnCancel
   with side-label row 6 overlay centered width 50 frame frmUpdPrcCost.

&ENDIF

/*----------------- INITIALIZATION -----------------------*/

&IF "{&OPSYS}" = "UNIX" &THEN

cmbPvnType:list-items    = ",с налог,без налог".
cmbPeriodType:list-items = ",полгода,квартал,месяц".
cmbProcType:list-items   = ",постоян,перемен".
cmbCostType:list-items   = ",постоян,перемен".
cmbAmtType:list-items    = ",постоян,перемен".

ASSIGN brwGraph:NUM-LOCKED-COLUMNS in frame frmBrwGraph = 2.
new-graph = false.
new-obj   = false.
new-obj-rec = false.

&ENDIF

def var vret as logical.

find lon where lon.lon = s-lon no-lock.
   find loncon where loncon.lon = s-lon no-lock.
   if lon.rdt = ?
   then do:
        bell.
        message "Дата регистрации !".
        pause.
        return.
   end.
   if lon.duedt = ?
   then do:
        bell.
        message "Срок !".
        pause.
        return.
   end.
   if lon.opnamt = ? or lon.opnamt <= 0
   then do:
        bell.
        message "Сумма договора !".
        pause.
        return.
   end.
   if lon.prem = ?
   then do:
        bell.
        message "Процентн.ставка !".
        pause.
        return.
   end.
   i = index(loncon.proc-no,"/").
   if i = 0
   then do:
        message "Начало платежа !".
        pause. 
        return.
   end.
   n = integer(substring(loncon.proc-no,1,i - 1)).
   j = r-index(loncon.proc-no,"/").
   l = integer(substring(loncon.proc-no,i + 1,j - i - 1)).
   m = integer(substring(loncon.proc-no,j + 1)).
   v-dt = date(l,n,m).
   v-day = n.
   if v-dt < lon.rdt or v-dt >= lon.duedt
   then do:
        message "Начало платежа !".
        pause.
        return.
   end.
   kopa-s = lon.opnamt.

   find lonhar where lonhar.lon = s-lon and lonhar.ln = 1 no-lock.
   find sysc where sysc.sysc = "LONPVN" no-lock no-error.
   
   find first falon where falon.lon = lon.lon no-lock no-error.
   if not available falon
   then do:
        new-graph = true.
        new-obj   = true.
        new-obj-rec = true.
        
        create falon.
        falon.lon = lon.lon.
        falon.falon = lon.lon + "001".
        falon.facif = lon.cif.
        falon.opnamt = lon.opnamt - ava-s - depo-s.
        falon.obj = loncon.objekts.
        ava-p = 20.
        pirk-p = 0.
        depo-mn = 0.
        dn = max((v-dt - lon.rdt),30).
        depo-s = 0.
        atal-p = 1.
        form-s = 10.
        sod1-p = 0.25.
        sod2-p = 0.5.
        sod3-p = 1.
        
        if available sysc then do:
           lon-pvn = sysc.deval.
           pvn-sum = kopa-s * lon-pvn / 100.
        end.
   end.
   else do:
        ava-s = lonhar.rez-dec[2].
        ava-p = round(lonhar.rez-dec[2] / kopa-s * 100, 2).
        if lonhar.rez-char[3]  <> ""  then lon-pvn = decimal(lonhar.rez-char[3]).
        else lon-pvn = 0.
        if lonhar.rez-char[4]  <> ""  then pvn-sum = decimal(lonhar.rez-char[4]).
        else pvn-sum = 0.
        graph-type = lonhar.rez-char[5].
        pirk-p     = lonhar.rez-dec[3].
        depo-mn    = lonhar.rez-int[2].
        dn         = lonhar.rez-int[4].
        /*dn = max((v-dt - lon.rdt),30).*/
        depo-s     = lonhar.rez-dec[4].
        atal-p     = lonhar.rez-dec[5].
        form-s     = lonhar.rez-dec[9].
        sod1-p     = lonhar.rez-dec[6].
        sod2-p     = lonhar.rez-dec[7].
        sod3-p     = lonhar.rez-dec[8].
        atal-s     = lonhar.rez-dec[10].
        if lonhar.rez-char[2] ne "" then do :
            for each wf :
                delete wf.
            end.
            do i = 1 to integer(num-entries(lonhar.rez-char[2]) / 2) :
                create wf.
                wf.nm = integer(entry(i + i - 1,lonhar.rez-char[2])).
                wf.rate = decimal(entry(i + i,lonhar.rez-char[2])).
            end.
        end.
        if lonhar.rez-char[7] ne "" then 
           pirk-s = decimal(lonhar.rez-char[7]).
        else pirk-s = 0.
   end.

   maks-pg = lon.prem.
   if ava-s = 0 then
      ava-s = round(ava-p * kopa-s / 100, 2).
   if pirk-s = 0 then
      pirk-s = round(pirk-p * kopa-s / 100, 2).
   if atal-s = 0
      then atal-s = round(atal-p * kopa-s / 100, 2).

   
   
   /* grafika tips */
   if available lonhar then do:
   
      &IF "{&OPSYS}" = "UNIX" &THEN
      
      if lonhar.rez-char[5] <> "" then do:
         if integer(entry(1,lonhar.rez-char[5])) > 0 then
            cmbPvnType    = cmbPvnType:entry(integer(entry(1,lonhar.rez-char[5]))).
         if integer(entry(2,lonhar.rez-char[5])) > 0 then
            cmbPeriodType = cmbPeriodType:entry(integer(entry(2,lonhar.rez-char[5]))).
         if integer(entry(3,lonhar.rez-char[5])) > 0 then
            cmbProcType   = cmbProcType:entry(integer(entry(3,lonhar.rez-char[5]))).
         if integer(entry(4,lonhar.rez-char[5])) > 0 then
            cmbCostType   = cmbCostType:entry(integer(entry(4,lonhar.rez-char[5]))).
         if num-entries(lonhar.rez-char[5]) > 4 then
            if integer(entry(5,lonhar.rez-char[5])) > 0 then
               cmbAmtType   = cmbAmtType:entry(integer(entry(5,lonhar.rez-char[5]))).
      end.

      &ELSEIF "{&OPSYS}" = "WIN32" &THEN
         define variable vcmbPvnType    as integer.
         define variable vcmbPeriodType as integer.
         define variable vcmbProcType   as integer.
         define variable vcmbCostType   as integer.
         define variable vcmbAmtType    as integer.

         if integer(entry(1,lonhar.rez-char[5])) > 0 then
            vcmbPvnType    = integer(entry(1,lonhar.rez-char[5])).
         if integer(entry(2,lonhar.rez-char[5])) > 0 then
            vcmbPeriodType = integer(entry(2,lonhar.rez-char[5])).
         if integer(entry(3,lonhar.rez-char[5])) > 0 then
            vcmbProcType   = integer(entry(3,lonhar.rez-char[5])).
         if integer(entry(4,lonhar.rez-char[5])) > 0 then
            vcmbCostType   = integer(entry(4,lonhar.rez-char[5])).
         if num-entries(lonhar.rez-char[5]) > 4 then
            if integer(entry(5,lonhar.rez-char[5])) > 0 then
               vcmbAmtType = integer(entry(5,lonhar.rez-char[5])).
      &ENDIF
  end.

&IF "{&OPSYS}" = "UNIX" &THEN
   
/*----------------- TRIGGER FOR OBJECT -------------------*/
ON CHOOSE OF btnGraph in frame d
DO:
  assign frame d ava-p ava-s lon-pvn pvn-sum pirk-p pirk-s depo-mn depo-s 
  dn atal-p atal-s form-s sod1-p sod2-p sod3-p.
  RUN GoGraph.
  new-graph = false.
  view frame d.
END. 

ON CHOOSE OF btnObject in frame d
DO:
  assign frame d ava-p ava-s lon-pvn pirk-p pirk-s depo-mn depo-s atal-p 
  dn atal-s form-s sod1-p sod2-p sod3-p.
  RUN GoObject.
  new-obj = false.
END.

ON CHOOSE OF btnAddInfo in frame d
DO:
  RUN GoAddInfo.
  view frame d.
END. 

ON /*CHOOSE OF btnOk in frame frmGraph OR*/ GO of frame frmGraph
DO:
  display " Подождите .." with frame frmWait row 10 centered overlay.
  pause 0.
  assign cmbPvnType cmbPeriodType cmbProcType cmbCostType cmbAmtType.
  if depo-mn <> 0 and (cmbProcType:lookup(cmbProcType:screen-value) <> 2 
                    or cmbCostType:lookup(cmbCostType:screen-value) <> 2 
                    or cmbAmtType:lookup(cmbAmtType:screen-value)  <> 2)
  then do:
     bell.
     message "При наличии гарантийного депозита - тип % ставки, сумма " skip 
             "платежа, неоплаченная стоимость должны быть постоянными !"
     view-as alert-box title "".
     hide frame frmWait no-pause.
     return no-apply.
  end.
  do:
     RUN MakeGraph ( cmbPvnType:lookup(cmbPvnType:screen-value),
                     cmbPeriodType:lookup(cmbPeriodType:screen-value),
                     cmbProcType:lookup(cmbProcType:screen-value),
                     cmbCostType:lookup(cmbCostType:screen-value),
                     cmbAmtType:lookup(cmbAmtType:screen-value)).
     if return-value <> "0" then return no-apply.
  end.
  hide frame frmWait no-pause.
END.

ON /*CHOOSE OF btnOk in frame frmBrwGraph OR*/ GO of frame frmBrwGraph
DO:  
   /* save graph if need */
   run CheckTotSum.
   if return-value = "false" then return no-apply.
   
   ja = false.
   do:
     message "Вы действительно уверены, что хотите сохранить график? " 
     view-as alert-box
     buttons YES-NO Title "Сохранить график ?" update ja.
   end.
   if keyfunction(lastkey) <> "ENDKEY" and keyfunction(lastkey) <> "END-ERROR"
   then do:
      if ja then do:
         assign frame frmGraph cmbPvnType cmbPeriodType 
                     cmbProcType cmbCostType cmbAmtType.
         run SaveGraph( cmbPeriodType:lookup(cmbPeriodType) ).
         display depo-s with frame d.
         /*hide frame frmBrwGraph no-pause.*/
         apply "LEAVE" to frame frmBrwGraph.
      end.
      else return no-apply.
   end.
   else do:
      display depo-s with frame d.
      apply "END-ERROR" to frame frmBrwGraph.
   end.
END.

ON CHOOSE OF btnOk in frame d OR GO of frame d
DO:  
   /* save lЁzing setup 
   if ava-p entered or ava-s entered or lon-pvn entered or pirk-p entered or
      pirk-s entered or depo-mn entered or depo-s entered or atal-p entered or
      atal-s or noform-s entered then new-graph = true.*/
      
   assign frame d ava-p ava-s lon-pvn pirk-p pirk-s depo-mn depo-s atal-p 
   atal-s form-s sod1-p sod2-p sod3-p.
   pause 0.
   if new-graph then do: /* new document */
      run GoGraph.
      if keyfunction(lastkey) = "ENDKEY" and keyfunction(lastkey) = "END-ERROR"
      then do:
         view frame d.
         return no-apply.
      end.
   end.
   if new-obj then do:
      run GoObject.
      if keyfunction(lastkey) = "ENDKEY" and keyfunction(lastkey) = "END-ERROR"
      then do:
         view frame d.
         return no-apply.
      end.
   end.
   rc = 0.
   run SaveFields.
   return.
END.

ON CHOOSE OF btnPrint in frame frmBrwGraph
DO:  
   /* print graph */
   output to rpt.img.

   find first cif where cif.cif = lon.cif no-lock no-error.
   if available cif then do:
      put 'Klients ' trim(trim(cif.prefix) + " " + trim(cif.name)) format 'x(45)' skip.
      put unformatted fill('=',114) skip(2).
   end.

   do:
      put unformatted fill('=',114) skip.
      put  "Nr. " "|" " Срок лиз. " format "x(10)" "|" "Лиз.% " "|" 
           "Неоплач.стоим" "|" " Оплата стоим" "|" "Fix1 Fix2 " "|" 
           "   Проценты " "|" 
           "Оплата лизинг" "|" "    Налог    " "|" "  Лиз.плат." skip.
           
      put unformatted fill('=',114) skip.
      for each Graph where not Graph.month begins "KOP" break by n:
         put month.
         put pay-date.
         put rate.
         put not-paied.
         put cost-pay.
         put fx-cost-pay.
         put fx-amt-pay.
         put prc-pay.
         put atalg-pay.
         put pvn-pay.
         put tot-pay.
         put skip.
      end.
      put unformatted fill('=',114) skip.
      find first Graph where Graph.month begins "KOP".
         put month.
         put space(6).
         put pay-date.
         put not-paied.
         put cost-pay.
         put space(8).
         put prc-pay.
         put atalg-pay.
         put pvn-pay.
         put tot-pay.
         put skip.
      put unformatted fill('=',114) skip.
   end.

   output close.
   pause 0.
   unix silent prit rpt.img.
   pause 0.
   message color normal cMessage.
END.

ON DEFAULT-ACTION of brwGraph
DO:
   if Graph.month begins "KOP" or
     (cmbAmtType:lookup(cmbAmtType:screen-value) in frame frmGraph <> 3 
     and Graph.month = "0") or
     (cmbProcType:lookup(cmbProcType:screen-value) <> 3 and
      cmbCostType:lookup(cmbCostType:screen-value) <> 3 and
      cmbAmtType:lookup(cmbAmtType:screen-value)   <> 3)
   then do:
      message color normal cMessage.
      bell.
      return no-apply.
   end.
   sv-cost-pay  = Graph.cost-pay.
   sv-not-paied = Graph.not-paied.

   outer: do:
      display Graph.month Graph.pay-date Graph.not-paied 
              Graph.rate Graph.cost-pay btnOk btnCancel 
              with frame frmUpdPrcCost.      
      update Graph.not-paied 
          when  cmbAmtType:lookup(cmbAmtType:screen-value)   in frame frmGraph = 3 
          Graph.rate
          when (cmbProcType:lookup(cmbProcType:screen-value) in frame frmGraph = 3 and
                Graph.month <> "0")
          Graph.cost-pay 
          when (cmbCostType:lookup(cmbCostType:screen-value) in frame frmGraph = 3 and
                Graph.month <> "0")
          btnOk btnCancel with frame frmUpdPrcCost.
      hide frame frmUpdPrcCost no-pause.
      
      if cmbCostType:lookup(cmbCostType:screen-value) in frame frmGraph = 3 then do:
         run CheckSum( recid(Graph) ).
         if return-value = "false" then undo,retry.
      end.

      if keyfunction(lastkey) <> "ENDKEY"    and
         keyfunction(lastkey) <> "END-ERROR" then do:
         assign frame frmUpdPrcCost Graph.rate Graph.cost-pay Graph.not-paied.
         if Graph.cost-pay  <> sv-cost-pay  then
            Graph.fx-cost-pay = true.
         if Graph.not-paied <> sv-not-paied then
            Graph.fx-amt-pay = true.
         run ChangeGraph.
         if return-value = "false" then undo,retry.
      end.
   end.
   message color normal cMessage.
END.

ON ANY-PRINTABLE of brwGraph
DO:
   if Graph.month begins "KOP" then do:
      bell.
      return no-apply.
   end.

   else if keylabel(lastkey) = "1" and 
   cmbAmtType:lookup(cmbAmtType:screen-value)   in frame frmGraph = 3 then do:
     Graph.fx-amt-pay  = not Graph.fx-amt-pay.
     run ChangeGraph.
   end.
   
   else if keylabel(lastkey) = "2" and
   cmbCostType:lookup(cmbCostType:screen-value) in frame frmGraph = 3 and
   Graph.month <> "0" then do:
     Graph.fx-cost-pay = not Graph.fx-cost-pay.
     run ChangeGraph.
   end.
   message color normal cMessage.
END.

on leave of ava-p in frame d do:
   if input ava-p <> ava-p then 
   inner: do:
      ava-s = round(INPUT ava-p * kopa-s / 100,2).
      if available lonliz then do:
         if lonliz.cam[1] > ava-s then do:
            message dMessage lonliz.cam[1]. pause.
            hide message.
            return no-apply.
         end.
         if lonliz.cam[1] > 0 then do on endkey undo,retry:
            ja = false.
            message "Заменить " ava-p " на " input ava-p " ?" update ja.
            if ja then assign ava-p.
            else do:
               input clear.
               display ava-p with frame d.
               undo, leave.
            end.
         end.
      end.
      display ava-s with frame d.
   end.
   if ava-p entered then do:
      new-graph = true.
      new-obj   = true.
   end.
   assign ava-p.
end.

on leave of ava-s in frame d do:
   if input ava-s <> ava-s then 
   inner: do:
      ava-p = round(input ava-s / kopa-s * 100,2).
      if available lonliz then do:
         if lonliz.cam[1] > input ava-s then do:
            message dMessage lonliz.cam[1]. pause.
            hide message.
            return no-apply.
         end.
         if lonliz.cam[1] > 0 then do on endkey undo,retry:
            ja = false.
            message "Заменить " ava-s " на " input ava-s " ?" update ja.
            if ja then assign ava-s.
            else do:
               input clear.
               display ava-s with frame d.
               undo, leave.
            end.
         end.
      end.
      display ava-p with frame d.
   end.
   
   if ava-s entered then do:
      new-graph = true.
      new-obj   = true.
   end.
   assign ava-s.
end.

on leave of lon-pvn in frame d do:
   if input lon-pvn <> lon-pvn then
   inner: do:
      if lonliz.cam[1] > 0 or lonliz.cam[3] > 0 or lonliz.cam[4] > 0 or
      lonliz.cam[5] > 0 then do on endkey undo,retry:
         ja = false.
         message "Заменить " lon-pvn " на " input lon-pvn " ?" update ja.
         if ja then assign lon-pvn.
         else do:
            input clear.
            display lon-pvn with frame d.
            undo, leave.
         end.
      end.
      pvn-sum = round(kopa-s * input lon-pvn / 100, 2).
      display pvn-sum with frame d.
   end.
   if lon-pvn entered then new-graph = true.
   assign lon-pvn.
end.

on leave of pirk-p in frame d do:
   if input pirk-p <> pirk-p then 
   inner: do:
      if lonliz.cam[1] > 0 or lonliz.cam[4] > 0 or
      lonliz.cam[5] > 0 then do on endkey undo,retry:
         ja = false.
         message "Заменить " pirk-p " на " input pirk-p " ?" update ja.
         if ja then assign pirk-p.
         else do:
            input clear.
            display pirk-p with frame d.
            undo, leave.
         end.
      end.
      pirk-s = round(input pirk-p * kopa-s / 100, 2).
      display pirk-s with frame d.
   end.
   if pirk-p entered then new-graph = true.
   assign pirk-p.
end.

on leave of pirk-s in frame d do:
   if input pirk-s <> pirk-s then 
   inner: do:
      if lonliz.cam[1] > 0 or lonliz.cam[4] > 0 or
      lonliz.cam[5] > 0 then do on endkey undo,retry:
         ja = false.
         message "Заменить " pirk-s " на " input pirk-s " ?" update ja.
         if ja then assign pirk-s.
         else do:
            input clear.
            display pirk-s with frame d.
            undo, leave.
         end.
      end.
      pirk-p = round(input pirk-s / kopa-s * 100, 2).
      display pirk-p with frame d.
   end.
   if pirk-s entered then new-graph = true.
   assign pirk-s.
end.

on leave of depo-mn in frame d do:
   if input depo-mn = 0 then depo-s = 0.
   display depo-s with frame d.
   if depo-mn entered then do:
      new-obj   = true.
      new-graph = true.
   end.
   assign depo-mn.
end.

on leave of atal-p in frame d do:
   if input atal-p <> atal-p then 
   inner: do:
      atal-s = round(input atal-p * kopa-s / 100, 2).
      if available lonliz then do:
         if lonliz.cam[4] > atal-s then do:
            message dMessage lonliz.cam[4]. pause.
            hide message.
            return no-apply.
         end.
         if lonliz.cam[4] > 0 then do on endkey undo,retry:
            ja = false.
            message "Заменить " atal-p " на " input atal-p " ?" update ja.
            if ja then assign atal-p.
            else do:
               input clear.
               display atal-p with frame d.
               undo, leave.
            end.
         end.
      end.
      display atal-s with frame d.
   end.
   if atal-p entered then new-graph = true.
   /*assign atal-p.*/
end.

on leave of atal-s in frame d do:
   if input atal-s <> atal-s then 
   inner: do:
      atal-p = round(input atal-s / kopa-s * 100, 2).
      if available lonliz then do:
         if lonliz.cam[4] > input atal-s then do:
            message dMessage lonliz.cam[4]. pause.
            hide message.
            return no-apply.
         end.
         if lonliz.cam[4] > 0 then do on endkey undo,retry:
            ja = false.
            message "Заменить " atal-s " на " input atal-s " ?" update ja.
            if ja then assign atal-s.
            else do:
               input clear.
               display atal-s with frame d.
               undo, leave.
            end.
         end.
      end.
      display atal-p with frame d.
   end.
   if atal-s entered then new-graph = true.
   /*assign atal-s.*/
end.

on leave of form-s in frame d do:
   if input form-s <> form-s then 
   inner: do:
      if available lonliz then do:
         if lonliz.cam[3] > input form-s then do:
            message dMessage lonliz.cam[3]. pause.
            hide message.
            return no-apply.
         end.
         if lonliz.cam[3] > 0 then do on endkey undo,retry:
            ja = false.
            message "Заменить " form-s " на " input form-s " ?" update ja.
            if ja then assign form-s.
            else do:
               input clear.
               display form-s with frame d.
               undo, leave.
            end.
         end.
      end.
   end.
   if form-s entered then new-graph = true.
   assign form-s.
end.

on leave of dn in frame d do:
   if input dn <> dn then 
   inner: do:
      if lonliz.cam[1] > 0 or lonliz.cam[4] > 0 or
      lonliz.cam[5] > 0 then do on endkey undo,retry:
         ja = false.
         message "Заменить " dn " на " input dn " ?" update ja.
         if ja then assign dn.
         else do:
            input clear.
            display dn with frame d.
            undo, leave.
         end.
      end.
   end.
   if dn entered then new-graph = true.
   /*assign dn.*/
end.

&ENDIF

&IF "{&OPSYS}" = "UNIX" &THEN

/*------------------------MAIN LOGIC ---------------------*/
find first lonliz where lonliz.lon = s-lon no-lock no-error.
if not available lonliz then do:
   create lonliz.
   lonliz.lon = lon.lon.
   lonliz.crc = lon.crc.
   lonliz.rdt = g-today.
   lonliz.who = g-ofc.
   lonliz.whn = today.
end.
payment0     = false.
payment1     = false.
payment-depo = false.

if available lonliz then do:
   if lonliz.cam[1] > 0 or lonliz.cam[3] > 0 or 
      lonliz.cam[4] > 0 or lonliz.cam[5] > 0 then payment0 = true.
   else payment0 = false.
   if lonliz.cam[5] > 0 then payment-depo = true.
   else payment-depo = false.
end.
else do:
   payment0 = false.
   payment-depo = false.
end.

find first lnsch where lnsch.lnn = s-lon and lnsch.f0 = 0 and
lnsch.flp > 0 no-lock no-error.
find first lnsci where lnsci.lni = s-lon and lnsci.f0 = 0 and
lnsci.flp > 0 no-lock no-error.
if available lnsch or available lnsci then do:
   payment1 = true.
end.
else payment1 = false.

rc = 1.
do on error undo,return:
   display ava-p
           ava-s
           lon-pvn
           pvn-sum
           pirk-p
           pirk-s 
           depo-mn
           depo-s
           dn
           atal-p
           atal-s
           form-s
           sod1-p
           sod2-p
           sod3-p
           btnGraph
           btnObject
           btnAddInfo
           btnOk
           btnCancel
           with frame d.

   do on error undo,leave:
      update ava-p 
             ava-s 
             lon-pvn 
             pirk-p 
             pirk-s 
             depo-mn when not payment-depo
             dn 
             atal-p 
             atal-s
             form-s
             sod1-p 
             sod2-p 
             sod3-p 
             btnGraph 
             btnObject 
             btnAddInfo
             btnOk 
             btnCancel 
             with frame d.
   
   end. /* do update */

end.

&ELSEIF "{&OPSYS}" = "WIN32" &THEN
   RUN MakeGraph ( vcmbPvnType, vcmbPeriodType, vcmbProcType, vcmbCostType, vcmbAmtType).
&ENDIF

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE nxt-month.
/*------------------------------------------------------------------------------
 #3.Programma nosaka n–koЅo mёnesi uzdotajam datumam
 #4.Ieeja - parametrs p-day (int)    svl 
 #5.Ieeja - parametrs p-dt1 (date)
 #6.Ieeja - parametrs p-mon (int)    period betweeen 2 dates (in month)
 #7.Izeja - parametrs p-dt2 (date)
 #8.Rezult–ts:
    dd = day(p-dt1)
    mm = month(p-dt1)
    gg = year(p-dt1)
    * ja mm = 12,tad gg = gg + 1,mm = 1
    * ja mm = 1,gg - garais gads,dd > 29,tad mm = 2,dd = 29
    * ja mm = 1,gg - Ёsais  gads,dd > 28,tad mm = 2,dd = 28
    * ja mm = 3 vai 5 vai 8 vai 10,dd > 30,tad mm = mm + 1,dd = 30
    * p–rёjos gadЁjumos mm = mm + 1
    p-dt2 = date(mm,dd,gg)
------------------------------------------------------------------------------*/
define input parameter  p-day  as int.
define input parameter  p-dt1  as date.
define input parameter  p-mon  as int.
define output parameter p-dt2  as date.
define variable         gd     as integer.
define variable         mn     as integer.
define variable         dn     as integer.
/*define variable         period as integer.*/
define variable         v-dt1  as date.
define variable         v-dt2  as date.

gd = year(p-dt1).
mn = month(p-dt1).
mn = mn + 1.

if mn gt 12 then do:
     gd = gd + 1.
     mn = 1.
end.
if p-day gt 28 then do:
    if mn eq 2 then do:
        if gd mod 4 eq 0 then p-day = 29.
        else p-day = 28.
    end.
    if (mn eq 4 or mn eq 6 or mn eq 9 or mn eq 11) and p-day eq 31 then 
    p-day = 30.
end.

p-dt2 = date(mn,p-day,gd).
if p-mon > 1 then do:
   do period = 1 to p-mon - 1:
      v-dt1 = p-dt2.      
      run nxt-month(p-day,v-dt1,1,output v-dt2).
      p-dt2 = v-dt2.
   end.
end.

return.     
end procedure.

&IF "{&OPSYS}" = "UNIX" &THEN

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE GoGraph.
hide message no-pause.
message color message eMessage.
display cmbPvnType cmbPeriodType cmbProcType cmbCostType cmbAmtType
       btnOk btnCancel with frame frmGraph.
update cmbPvnType cmbPeriodType cmbProcType cmbCostType cmbAmtType 
       btnOk btnCancel with frame frmGraph.
hide frame frmGraph no-pause.
pause 0.
hide message no-pause.
END PROCEDURE.
/*---------------------------------------------------------------*/

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE GoObject.
/* Objects */   

   if new-obj-rec then do:
      find first falon where falon.lon = lon.lon no-error.
      if available falon then do:
         falon.opnamt = lon.opnamt - ava-s - depo-s.
         release falon.
      end.
   end.
   
   find facif where facif.facif = lon.cif no-lock no-error.
   if not available facif
   then do:
        find cif where cif.cif = lon.cif no-lock.
        v-pss = cif.pss.
        c-dt = cif.jel.
        if index(c-dt,"&") = 0
        then v-dt3 = ?.
        else do:
             c-dt = substring(c-dt,1,index(c-dt,"&") - 1).
             i = integer(substring(c-dt,1,index(c-dt,"/") - 1)).
             c-dt = substring(c-dt,index(c-dt,"/") + 1).
             j = integer(substring(c-dt,1,index(c-dt,"/") - 1)).
             c-dt = substring(c-dt,index(c-dt,"/") + 1).
             k = integer(c-dt).
             if i * j * k > 0
             then v-dt3 = date(j,i,k).
             else v-dt3 = ?.
        end.
        repeat:
           find facif where facif.fanrur = v-pss no-lock no-error.
           if available facif
           then v-pss = v-pss + "Z".
           else leave.
        end.
        create facif.
        facif.facif = cif.cif.
        facif.fanrur = v-pss.
        facif.fadtur = v-dt3.
        facif.name = trim(trim(cif.prefix) + " " + trim(cif.name)).
        facif.addr[1] = cif.addr[1].
        facif.addr[2] = cif.addr[2].
        facif.addr[3] = cif.addr[3].
        facif.who = userid("bank").
        facif.whn = g-today.
   end.

   {s-edit.i
     &rz         = "2"
     &var        = "var"
     &file       = "falon"
     &index      = "falon"
     &where      = "falon.lon = lon.lon"
     &i          = "i"
     &j          = "j"
     &n          = "5"
     &key        = "falon"
     &min-key    = "min-lon"
     &max-key    = "max-lon"
     &frame      = "falon"
     &postfind   = "l = integer(substring(falon.falon,11)). "
     &display    = "falon.falon falon.rez-dec[1] falon.opnamt falon.obj"
     &preupdate  = " "
     &update     = "falon.rez-dec[1] falon.opnamt falon.obj"
     &postupdate = " "
     &dispkopa   = " "
     &predelete  = "find first falon1 where falon1.lon = lon.lon
      and falon1.falon <> falon.falon no-error. if not available falon1
      then undo,retry. find first fagra where fagra.falon = falon.falon
      and fagra.pf = 'F' no-error. if available fagra then undo,retry. 
      v-key = falon.falon. "
     &postdelete = "for each fagra where fagra.falon = v-key:
      delete fagra. end. "
     &precreate  = "ja = no. message 'Прибавить новую запись ? (Y/N)'
      update ja. if not ja then do: find last falon use-index falon where 
      falon.lon = lon.lon exclusive-lock. display falon.falon with frame
      falon. next. end. s1 = 0. for each falon1 where falon1.lon = lon.lon
      no-lock: s1 = s1 + falon1.opnamt. end. "
     &postcreate = "l = l + 1. falon.lon = lon.lon. falon.falon = lon.lon +
      string(l,'999'). falon.opnamt = lon.opnamt - ava-s - depo-s - s1. 
      if falon.opnamt < 0 then falon.opnamt = 0. falon.gl = lon.gl. falon.facif
      = lon.cif. "
     &end = "s1 = 0.
      for each falon1 where falon1.lon = lon.lon no-lock:
      s1 = s1 + falon1.opnamt. end. s2 = round(lon.opnamt - ava-s - depo-s,2).
      s1 = round(s1,2).
      if s2 <> s1 then do: if s2 > s1 then do: find first falon where
      falon.lon = lon.lon exclusive-lock no-error. falon.opnamt = 
      falon.opnamt + s2 - s1. end. else repeat while s1 <> s2:
      find first falon where falon.lon = lon.lon and 
      falon.opnamt - falon.dam[1] > 0 exclusive-lock no-error.
      s3 = falon.opnamt -
      falon.dam[1]. if s3 >= s1 - s2 then do: falon.opnamt = falon.opnamt -
      (s1 - s2). s1 = s2. end. else do: falon.opnamt = falon.opnamt - s3.
      s1 = s1 - s3. end. end. end. s1 = 0.
      for each falon1 where falon1.lon = lon.lon no-lock: 
      s1 = s1 + falon1.opnamt. end. if s1 > 0 then do: find gl where
      gl.gl = lon.gl no-lock. for each falon where falon.lon = 
      lon.lon exclusive-lock: falon.dam[2] = 0. for each fagra where
      fagra.falon = falon.falon and fagra.pf = 'P' and (fagra.gl = lon.gl or
      fagra.gl = gl.gl1) exclusive-lock:
      delete fagra. end. for each lnsch where lnsch.lnn = lon.lon and
      lnsch.f0 > 0 and lnsch.flp = 0 and lnsch.fpn = 0 no-lock: create
      fagra. fagra.falon = falon.falon. fagra.lon = lon.lon. fagra.dt =
      lnsch.stdat. fagra.pf = 'P'. fagra.dc = 'C'. fagra.gl = lon.gl.
      fagra.jh = 0. fagra.amt = falon.opnamt / s1 * lnsch.stval. fagra.gl1 =
      lon.gl. end. 
      for each lnsci where lnsci.lni = lon.lon and
      lnsci.f0 > 0 and lnsci.flp = 0 and lnsci.fpn = 0 no-lock: create
      fagra. fagra.falon = falon.falon. fagra.lon = lon.lon. fagra.dt =
      lnsci.idat. fagra.pf = 'P'. fagra.dc = 'C'. fagra.gl = lon.gl. 
      fagra.gl1 = gl.gl1.
      fagra.jh = 0. fagra.amt = falon.opnamt / s1 * lnsci.iv-sc. falon.dam[2] =
      falon.dam[2] + fagra.amt. end. end. end. "}.

   rc = 0.
   hide frame falon no-pause.
   pause 0 no-message.
END PROCEDURE.
/*---------------------------------------------------------------*/

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE GoAddInfo.
define buffer blonhar for lonhar.

ON HELP of cFacifFacif IN FRAME frmAddInfo
DO:
   lUserPressOk = no.
   run facifh.
   cFacifFacif = cgFacifFacif.
   find first facif where facif.facif = cgFacifFacif no-lock no-error.
   if available facif then do:
      {s-liz1.i}
      display "{&glFacifDisplay1}" with frame frmAddInfo.
   end.
END.

ON HELP of cFacifFacifApd  IN FRAME frmAddInfo
DO:
   lUserPressOk = no.
   run facifh.
   cFacifFacifApd = cgFacifFacif.
   find first facif where facif.facif = cgFacifFacif no-lock no-error.
   if available facif then do:
      {s-liz2.i}
      display "{&glFacifDisplayApd}" with frame frmAddInfo.
   end.
END.

ON INSERT of cFacifFacif, cFacifFacifApd IN FRAME frmAddInfo
DO:
   run lnfacif.
   view frame lon.
END.

ON GO OF FRAME frmAddInfo
DO:
   assign frame frmAddInfo cFacifFacif cFacifFacifApd.
   find first blonhar where blonhar.lon = s-lon exclusive-lock no-error.
   if available blonhar then do:
      blonhar.rez-char[10] = cFacifFacif + "," + cFacifFacifApd.
   end.
END.

ON RETURN OF cFacifFacif in frame frmAddInfo
DO:
   assign frame frmAddInfo cFacifFacif.
   if cFacifFacif = "" then do:
      run FacifClear.
   end.
   else do:
      find first facif where facif.facif = cFacifFacif no-lock no-error.
      if available facif then do:
         {s-liz1.i}
         display "{&glFacifDisplay1}" with frame frmAddInfo.
      end.
      else do:
         run FacifClear.
         message "База данных не найдена !".
         pause no-message.
         hide message no-pause.
      end.
   end.
END.

ON RETURN OF cFacifFacifApd in frame frmAddInfo
DO:
   assign frame frmAddInfo cFacifFacifApd.
   if cFacifFacifApd = "" then do:
      run FacifApdClear.
   end.
   else do:
      find first facif where facif.facif = cFacifFacifApd no-lock no-error.
      if available facif then do:
         {s-liz2.i}
         display "{&glFacifDisplayApd}" with frame frmAddInfo.
      end.
      else do:
         run FacifApdClear.
         message "База данных не найдена !".
         pause no-message.
         hide message no-pause.
      end.
   end.
END.

/************************ MAIN LOGIC **************************/
find first blonhar where blonhar.lon = s-lon no-lock no-error.
if available blonhar then do:
   if blonhar.rez-char[10] <> "" then do:
      find first facif where facif.facif = entry(1,blonhar.rez-char[10]) 
      no-lock no-error.
      if available facif then do:
         {s-liz1.i}
      end.
      if num-entries(blonhar.rez-char[10]) > 1 then do:
         find first facif where facif.facif = entry(2,blonhar.rez-char[10])
         no-lock no-error.
         if available facif then do:
            {s-liz2.i}
         end.
      end.
   end.
   else do:
      run FacifClear.
      run FacifApdClear.
   end.
end.

hide message no-pause.
message color normal gMessage.
display "{&glFacifDisplay1}"   with frame frmAddInfo.        
display "{&glFacifDisplayApd}" with frame frmAddInfo.

do on endkey undo,leave:
   update  cFacifFacif
           cFacifFacifApd
           btnOk 
           btnCancel 
           with frame frmAddInfo.
end.

hide frame frmAddInfo no-pause.
pause 0.
hide message no-pause.
view frame d.
END PROCEDURE.
/*---------------------------------------------------------------*/

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE FacifClear:
cFacifName    = "".
cFacifAddr    = "".
cFacifTel1    = "".
cFacifTel2    = "".
cFacifFax     = "".
cFacifBanka   = "".
cFacifKonts   = "".
cFacifFanrur  = "".
cFacifPvnMaks = "".
display "{&glFacifDisplay1}" with frame frmAddInfo.
pause 0.
END PROCEDURE.
/*----------------------------------------------------------------*/

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE FacifApdClear:
cFacifNameApd    = "".
cFacifAddrApd    = "".
display "{&glFacifDisplayApd}" with frame frmAddInfo.
pause 0.
END PROCEDURE.
/*----------------------------------------------------------------*/
&ENDIF

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE MakeGraph.
define input parameter PvnType    as integer.
define input parameter PeriodType as integer.
define input parameter ProcType   as integer.
define input parameter CostType   as integer.
define input parameter AmtType    as integer.

def var per-pay       as decimal decimals 10. /* periodical payment in month */
def var prc-mon       as decimal decimals 10.

period = 1.

&IF "{&OPSYS}" = "UNIX" &THEN

if PvnType = 1 or PeriodType = 1 or ProcType = 1 or CostType = 1
then do:
   bell.
   message "J–b­t aizpildЁtiem visiem laukiem !" view-as alert-box.
   return "1".
end.

&ENDIF

case PeriodType:
   when 2 then period = 6.    /* p­sgads  */
   when 3 then period = 3.    /* kvart–ls */
   when 4 then period = 1.    /* menesis  */
end case.

v-dt1 = v-dt.
mn = 0.
repeat:
  /* schitaem kolichestvo mesjacev */
  mn = mn + 1.
  if month(v-dt1) = month(lon.duedt ) and 
  year(v-dt1) = year(lon.duedt )
  then leave.

  run nxt-month(v-day,v-dt1,1,output v-dt2).
  v-dt1 = v-dt2.
end.

mn = mn / period. /* po koliўestvu plate·ei */


&IF "{&OPSYS}" = "UNIX" &THEN

if ProcType = 3 then do:
   for each wf :
      displ wf with frame pr2 overlay down centered row 4.
   end.
   v-ans = yes.
   if lonhar.rez-char[2] ne "" then do on endkey undo,leave:
      message "Viss k–rtЁb– ? " update v-ans.
   end.
   else v-ans = no.
   hide frame pr2 no-pause.
   if keyfunction(lastkey) = "ENDKEY" OR keyfunction(lastkey) = "END-ERROR"
   then return "0".   

   v-edit = not v-ans.
   if not v-ans then
   repeat :
   for each wf :
      delete wf.
   end.
   k = mn.
   
   repeat on error undo,leave on endkey undo,leave:
      create wf.
      wf.nm = 0.
      wf.rate = 0.
      update wf.nm format ">>9" label "Период времени"
      validate(wf.nm le k ,"You are wrong") 
      wf.rate label "Ставка" with frame pr side-label centered row 12 overlay
      Title "Остаток за период " + string(k,">>9").
      k = k - wf.nm.
      hide frame pr no-pause.
      if k eq 0 then leave.
   end.
   hide frame pr no-pause.
   if keyfunction(lastkey) = "ENDKEY" OR keyfunction(lastkey) = "END-ERROR"
   then return "0".
   
   if k lt 0 then undo,retry.
   for each wf where wf.nm eq 0 and wf.rate eq 0 :
      delete wf.
   end.
   for each wf :
      displ wf with frame pr1 overlay down centered row 4.
   end.
   v-ans = yes.
   do:
      message "Все в порядке ? " update v-ans.
   end.
   hide frame pr1 no-pause.
   if keyfunction(lastkey) = "ENDKEY" OR keyfunction(lastkey) = "END-ERROR"
   then return "0".
   
   if v-ans then leave.
   end.
end.
else do:
   for each wf :
      delete wf.
   end.
end.

&ENDIF

if ProcType = 3 then do:
   run CreateGraphFile(mn,period,0).
end.
else do:
   run CreateGraphFile(mn,period,maks-pg).
end.

run FillGraphFile.

open query qryGraph for each Graph no-lock by Graph.n.

&IF "{&OPSYS}" = "UNIX" &THEN

do on endkey undo,leave on error undo,leave:
   hide message no-pause.
   status input off.
   message color normal cMessage.
   display brwGraph btnOk btnCancel btnPrint with frame frmBrwGraph.
   update  brwGraph btnOk btnCancel btnPrint with frame frmBrwGraph.
end.
pause 0.
hide frame frmBrwGraph no-pause.
hide message no-pause.
status default.

if keyfunction(lastkey) = "ENDKEY" OR keyfunction(lastkey) = "END-ERROR"
then return "0".

&ENDIF

return "0".
END PROCEDURE.
/*---------------------------------------------------------------*/

&IF "{&OPSYS}" = "UNIX" &THEN

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE SaveGraph.
define input parameter PeriodType as integer.

case PeriodType:
   when 2 then period = 6.    /* p­sgads  */
   when 3 then period = 3.    /* kvart–ls */
   when 4 then period = 1.    /* menesis  */
end case.

def var pr-sum  as integer.
def var pr-cnt  as integer.
def var pr-rate as decimal.
def var sv-pr-rate as decimal.

/* obnovlenie faila wf */
pr-rate = 0.
find first wf no-error.
if available wf then do:
   for each wf:
      delete wf.
   end.
   find first Graph no-error.
   if available Graph then do:
      for each Graph where Graph.month <> "0" and 
          (not Graph.month begins "KOP") break by Graph.n:
          if first(Graph.n) then do:
             pr-rate = Graph.rate.
             pr-sum  = 0.
          end.
          pr-sum = pr-sum + 1. 
          if pr-rate <> Graph.rate and not last(Graph.n) then do:
             create wf.
             wf.nm   = pr-sum - 1.
             wf.rate = pr-rate.
             release wf.
             pr-rate = Graph.rate.
             pr-sum  = 1.
          end.
          if last(Graph.n) then do:
             if pr-rate <> Graph.rate then do:
                create wf.
                wf.nm   = pr-sum - 1.
                wf.rate = pr-rate.
                release wf.
                pr-rate = Graph.rate.
                pr-sum  = 1.
             end.
             create wf.
             wf.nm   = pr-sum.
             wf.rate = Graph.rate.
             release wf.
          end.
      end.
  end.
end.

find first lonhar where lonhar.lon = s-lon and lonhar.ln = 1 exclusive-lock.
if available lonhar then do:
   lonhar.rez-dec[2] = ava-s.  
   lonhar.rez-dec[3] = pirk-p.
   lonhar.rez-int[2] = depo-mn.
   lonhar.rez-int[4] = dn.
   lonhar.rez-dec[4] = depo-s.
   lonhar.rez-dec[5] = atal-p.
   lonhar.rez-dec[6] = sod1-p.
   lonhar.rez-dec[7] = sod2-p.
   lonhar.rez-dec[8] = sod3-p.
   lonhar.rez-dec[9] = form-s.
   lonhar.rez-dec[10] = atal-s.
   lonhar.rez-char[2] = "".
   lonhar.rez-char[6] = "".
   lonhar.rez-char[7] = string(pirk-s).
   lonhar.rez-char[9] = "".
   
   for each wf:
     if lonhar.rez-char[2] eq "" then 
        lonhar.rez-char[2] = string(wf.nm,"999") + "," + string(wf.rate,"999.99").
     else
        lonhar.rez-char[2] = lonhar.rez-char[2] + "," +
        string(wf.nm,"999") + "," + string(wf.rate,"999.99").
   end.

   for each Graph where Graph.fx-cost-pay break by Graph.n:
       if lonhar.rez-char[6] eq "" then 
          lonhar.rez-char[6] = Graph.month + "," + string(Graph.cost-pay,">>>>>>>>>>>>9.99").
       else
          lonhar.rez-char[6] = lonhar.rez-char[6] + "," +
          Graph.month + "," + string(Graph.cost-pay,">>>>>>>>>>>>9.99").
   end.
   
   for each Graph where Graph.fx-amt-pay break by Graph.n:
       if lonhar.rez-char[9] eq "" then
          lonhar.rez-char[9] = Graph.month + "," + string(Graph.not-paied,">>>>>>>>>>>>9.99").
       else
          lonhar.rez-char[9] = lonhar.rez-char[9] + "," + 
          Graph.month + "," + string(Graph.not-paied,">>>>>>>>>>>>9.99").
   end.

   lonhar.rez-char[3] = string(lon-pvn,">>>>>>>>>>>>9.99").
   lonhar.rez-char[4] = string(pvn-sum,">>>>>>>>>>>>9.99").

   lonhar.rez-char[5] = string(cmbPvnType:lookup(cmbPvnType) 
                              in frame frmGraph,"9") + "," +
                        string(cmbPeriodType:lookup(cmbPeriodType)
                              in frame frmGraph,"9") + "," +
                        string(cmbProcType:lookup(cmbProcType)
                              in frame frmGraph,"9") + "," +
                        string(cmbCostType:lookup(cmbCostType)
                              in frame frmGraph,"9") + "," +
                        string(cmbAmtType:lookup(cmbAmtType)
                              in frame frmGraph,"9").
end.

/*-------zapisivaem znachenija v lonliz.dam[] -------------*/
find first lonliz where lonliz.lon = lon.lon no-error.
if not available lonliz then do:
   create lonliz.
   lonliz.lon = lon.lon.
   lonliz.crc = lon.crc.
   lonliz.rdt = g-today.
   lonliz.who = g-ofc.
   lonliz.whn = today.
end.
if available lonliz then do:
   lonliz.dam[3] = form-s.    /* noformeЅana */
   lonliz.dam[4] = atal-s.    /* atalgojums */
   release lonliz.
end.

/* udalenie grafikov */

for each lnscg where lnscg.lng = s-lon and lnscg.f0 > 0 and
   lnscg.flp = 0 and lnscg.fpn = 0:
   delete lnscg.
end.
for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 and
   lnsch.flp = 0 and lnsch.fpn = 0:
   delete lnsch.
end.
for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0 and
   lnsci.flp = 0 and lnsci.fpn = 0:
   delete lnsci.
end.

k = mn - depo-mn.
v-dt1 = v-dt.

do i = 1 to mn:
   v-dt2 = v-dt1.
   create lnsch.
   lnsch.lnn = s-lon.
   lnsch.f0 = i. 
   lnsch.stdat = v-dt2. 
   lnsch.schn = string(lnsch.f0,"zzz.") + " .  ". 

   find first Graph where Graph.n eq i + 1 no-error.
      lnsch.stval = Graph.cost-pay.
      create lnsci.
      lnsci.f0 = i.
      lnsci.lni = s-lon.
      lnsci.idat = v-dt2.
      if i le k then
         lnsci.iv-sc = Graph.prc-pay.
      else 
         lnsci.iv-sc = 0.
      lnsci.schn = string(lnsci.f0,"zzz.")
                          + string(lnsci.fpn,"z.")
                          + string(lnsci.flp,"zzz").
      run nxt-month(v-day,v-dt1,period,output v-dt2).
      v-dt1 = v-dt2.
end.
END PROCEDURE.
/*---------------------------------------------------------------*/

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE SaveFields.

find first lonhar where lonhar.lon = s-lon and lonhar.ln = 1 exclusive-lock.
if available lonhar then do:
   lonhar.rez-dec[6] = sod1-p.
   lonhar.rez-dec[7] = sod2-p.
   lonhar.rez-dec[8] = sod3-p.
   lonhar.rez-dec[9] = form-s.
end.

/*-------zapisivaem znachenija v lonliz.dam[] -------------*/
find first lonliz where lonliz.lon = lon.lon no-error.
if not available lonliz then do:
   create lonliz.
   lonliz.lon = lon.lon.
   lonliz.crc = lon.crc.
   lonliz.rdt = g-today.
   lonliz.who = g-ofc.
   lonliz.whn = today.
end.
if available lonliz then do:
   lonliz.dam[3] = form-s.    /* noformeЅana */
   lonliz.dam[4] = atal-s.    /* atalgojums  */
   release lonliz.
end.
END PROCEDURE.
/*---------------------------------------------------------------*/

&ENDIF

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE Formula_Annuiteta.
define input parameter kopa-s   as decimal decimals 10.
define input parameter ava-s    as decimal decimals 10.
define input parameter pirk-s   as decimal decimals 10.
define input parameter prc-mon  as decimal decimals 10.
define input parameter mn       as integer.
define input parameter depo-mn  as integer.

define variable per-pay as decimal decimals 10.

per-pay = round( ((kopa-s - ava-s) - (pirk-s / 
  exp((1 + prc-mon),(mn - depo-mn)))) / (((1 - (1 / exp(( 1 + prc-mon),
  (mn - depo-mn)))) / prc-mon) + depo-mn), 2).

if prc-mon = 0 then per-pay = 0.
if per-pay > 0 then return string(per-pay, ">>>>>>>>>>>>>>9.99").
else if per-pay = 0 then return "0".
else return "".

END PROCEDURE.
/*---------------------------------------------------------------*/

&IF "{&OPSYS}" = "UNIX" &THEN

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE ChangeGraph.
def var svGraph as rowid.
def var iCurrentBrowseRow as integer. 
DEF VAR stat AS LOGICAL.

svGraph = rowid(Graph).
iCurrentBrowseRow = brwGraph:FOCUSED-ROW in frame frmBrwGraph.
run FillGraphFile.
if return-value = "false" then return "false".

open query qryGraph for each Graph no-lock by Graph.n.
brwGraph:REFRESHABLE in frame frmBrwGraph = false.
iCurrentBrowseRow = 1.
stat = brwGraph:set-repositioned-row(iCurrentBrowseRow, "CONDITIONAL").

reposition qryGraph to rowid svGraph no-error.

brwGraph:REFRESHABLE in frame frmBrwGraph = true.
pause 0.

END PROCEDURE.
/*---------------------------------------------------------------*/

&ENDIF

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE FillGraphFile.

def buffer cGraph for Graph.
def buffer dGraph for Graph.

def var irow as integer.
def var imon as integer.
def var per-pay       as decimal decimals 10. /* periodical payment in month */
def var prc-mon       as decimal decimals 10.

def var tot-not-paied as decimal decimals 10.
def var tot-cost-pay  as decimal decimals 10.
def var tot-prc-pay   as decimal decimals 10.
def var tot-pvn-pay   as decimal decimals 10.
def var tot-tot-pay   as decimal decimals 10.

def var sv-not-paied  as decimal decimals 10 no-undo.
def var sv-prc        as decimal decimals 10 no-undo.
def var sv-apm        as decimal decimals 10 no-undo.
def var nxt-dt        as date    no-undo.
def var sv-pirk-s     as decimal decimals 10.

def var pr-sum        as integer.
def var pr-cnt        as integer.
def var pr-cnt-atl    as integer.
def var pr-rate       as decimal.
def var depo-mn-atl   as integer.
def var depo-mn-cnt   as integer.
def var sv-pvn-pay    as decimal.

     /*--------- raschet summi deposita -----------*/
     if depo-mn <> 0 then do:
        depo-s  = 0.
        pr-cnt  = mn.
        prc-mon = (maks-pg / 12 * period) / 100.
        sv-apm  = round((kopa-s - ava-s - pirk-s) * pr-cnt / mn, 2).
       
        if sv-not-paied >= (pirk-s + sv-apm) then sv-pirk-s = sv-not-paied - sv-apm.
        else sv-pirk-s = pirk-s.

        /* formula annuiteta */
        run Formula_Annuiteta(kopa-s,ava-s,pirk-s,prc-mon,pr-cnt,depo-mn).

        if return-value <> "" then
           per-pay = decimal(return-value).
        else if return-value = "0" then
           per-pay = 0.
        else do:
           bell.
           message "Месячнй платеж < 0 !" view-as alert-box.
           return "false".
        end.
        depo-s = depo-mn * per-pay.
     end.
     else depo-s = 0.
     
     imon = 0.
     irow = 0.

     /*-------------- oplata avansa ---------------*/
     find first Graph where Graph.month = "0" no-error.
     if available Graph then do:
        Graph.prc-pay      = 0.
        Graph.atalg-pay    = atal-s.
        /*Graph.pvn-pay      = round((ava-s * lon-pvn / 100),2).*/
        if not Graph.fx-amt-pay then
           Graph.not-paied    = kopa-s.
        Graph.cost-pay     = ava-s + depo-s.
        if lon-pvn > 0 then do:
           Graph.pvn-pay      = round(( (Graph.cost-pay + Graph.atalg-pay) 
                              * lon-pvn / 100),2).
        end.
        else do:
           find sysc where sysc.sysc = "LONPVN" no-lock no-error.
           if available sysc then do:
              Graph.pvn-pay      = round((Graph.atalg-pay * sysc.deval / 100),2).
           end.
        end.
        Graph.tot-pay      = Graph.cost-pay + Graph.prc-pay + Graph.atalg-pay + Graph.pvn-pay.
        Graph.prc-cost-pay = round((Graph.cost-pay / kopa-s * 100),2).
   
        sv-not-paied       = Graph.not-paied - Graph.cost-pay.
        if Graph.not-paied = 0 then sv-not-paied = 0.
        
        irow = irow + 1.
        imon = imon + 1.
        release Graph.
     end.
 
     /* raschet 1 plateza */
     pr-sum  = 0.
     pr-rate = 0.
     pr-cnt  = 0.
     savePeriodSum = 0.
     find first cGraph where cGraph.month = "1" no-error.
     if available cGraph then do:
        if cGraph.fx-amt-pay then sv-not-paied = cGraph.not-paied.
     end.
     {s-lizgr.i
        &count_period = yes}
        pr-cnt-atl = pr-cnt.
      

       /*--------------- 1 mesjac oplati --------------*/
       find first Graph where Graph.month = "1" no-error.
       if available Graph and imon <= pr-sum then do:
          if Graph.fx-amt-pay then
                Graph.prc-pay   = round((Graph.not-paied * prc-mon),2).
             else
                Graph.prc-pay   = round((sv-not-paied * prc-mon),2).
          Graph.atalg-pay = 0.
          if depo-mn = 0 then do: /* bez depozita */
             if imon <> mn then do:
                if not Graph.fx-cost-pay then do:
                   if sv-not-paied > per-pay then
                      Graph.cost-pay = per-pay - Graph.prc-pay.
                   else Graph.cost-pay = sv-not-paied.
                end.
             end.
             else Graph.cost-pay = sv-not-paied - pirk-s.
          end.
          else do:
             if mn - imon > depo-mn then do:
                if sv-not-paied > per-pay then do:
                   if not Graph.fx-cost-pay then
                      Graph.cost-pay = per-pay - Graph.prc-pay.
                end.
                else Graph.cost-pay = sv-not-paied.
             end.
             else if mn - imon = depo-mn then do:
                Graph.cost-pay = sv-not-paied - pirk-s.
             end.
             else Graph.cost-pay = 0.
          end.
          Graph.pvn-pay   = round((Graph.cost-pay * lon-pvn / 100),2).
          if not Graph.fx-amt-pay then
             Graph.not-paied = sv-not-paied.
             
          sv-not-paied    = Graph.not-paied - Graph.cost-pay.
       
          /* popravka na raznicu v dnjah mezdu zakljuchenuem dogovora i 1 platezhom*/
          Graph.prc-pay   = round((Graph.prc-pay / 30) * dn, 2).
        
          Graph.tot-pay   = Graph.cost-pay + Graph.prc-pay + Graph.atalg-pay 
                          + Graph.pvn-pay.
          Graph.prc-cost-pay = round((Graph.cost-pay / kopa-s * 100),2).
       
          irow = irow + 1.
          imon = imon + 1.
          pr-cnt-atl = pr-cnt-atl - 1.
          /*if Graph.fx-cost-pay or Graph.fx-amt-pay then do:
             if Graph.fx-amt-pay then sv-not-paied = Graph.not-paied.
             {s-lizgr1.i}
          end.*/
          release Graph.
       end.

       /* ostalnie viplati */
       do while imon <= mn:
          find first Graph where Graph.month = string(imon) no-error.
          if available Graph then do:
             if imon > pr-sum 
             or (Graph.fx-cost-pay or Graph.fx-amt-pay)
             then 
             inner: do:
                pr-cnt = 0.
                find first cGraph where cGraph.month = string(imon) no-error.
                if available cGraph then do:
                   if Graph.fx-amt-pay then sv-not-paied = cGraph.not-paied.
                   {s-lizgr.i
                      &count_period = yes}
                      pr-cnt-atl = pr-cnt. 
                end.
             end. /* if imon > pr-sum */
             /*else if Graph.fx-cost-pay /*or Graph.fx-amt-pay*/ then do:
                if Graph.fx-amt-pay then sv-not-paied = Graph.not-paied.
                {s-lizgr1.i}
             end.*/
          end.
          else return.

          /* zapolnenie tablici */
          if depo-mn = 0 then
             if Graph.fx-amt-pay then
                Graph.prc-pay   = round((Graph.not-paied * prc-mon),2).
             else
                Graph.prc-pay   = round((sv-not-paied * prc-mon),2).
          else do:
             if mn - imon < depo-mn then
                Graph.prc-pay = 0.
             else
                Graph.prc-pay = round((sv-not-paied * prc-mon),2).
          end.
          Graph.atalg-pay = 0.
          if depo-mn = 0 then do: /* bez depozita */
             if imon <> mn then do:
                if sv-not-paied > per-pay then do:
                   if not Graph.fx-cost-pay then
                      Graph.cost-pay = per-pay - Graph.prc-pay.
                end.
                else Graph.cost-pay = sv-not-paied.
             end.
             else Graph.cost-pay = sv-not-paied - pirk-s.
          end.
          else do:
             if mn - imon > depo-mn then do:
                if sv-not-paied > per-pay then do:
                   if not Graph.fx-cost-pay then
                      Graph.cost-pay = per-pay - Graph.prc-pay.
                end.
                else Graph.cost-pay = sv-not-paied.
             end.
             else if mn - imon = depo-mn then do:
                Graph.cost-pay = sv-not-paied - pirk-s.
             end.
             else Graph.cost-pay = 0.
          end.
          
          Graph.pvn-pay   = round((Graph.cost-pay * lon-pvn / 100),2).
          if not Graph.fx-amt-pay then
             Graph.not-paied = sv-not-paied.
          Graph.tot-pay   = Graph.cost-pay + Graph.prc-pay + Graph.atalg-pay 
                          + Graph.pvn-pay.
          Graph.prc-cost-pay = round((Graph.cost-pay / kopa-s * 100),2).
          
          sv-not-paied    = Graph.not-paied - Graph.cost-pay.
          
          irow = irow + 1.
          imon = imon + 1.
          pr-cnt-atl = pr-cnt-atl - 1.
          release Graph.
       end.

       tot-cost-pay  = 0.
       tot-prc-pay   = 0.
       tot-pvn-pay   = 0.
       tot-tot-pay   = 0.
       for each Graph where not Graph.month begins "KOP":
          tot-not-paied = sv-not-paied.
          tot-cost-pay = tot-cost-pay + Graph.cost-pay.
          tot-prc-pay  = tot-prc-pay  + Graph.prc-pay.
          tot-pvn-pay  = tot-pvn-pay  + Graph.pvn-pay.
          tot-tot-pay  = tot-tot-pay  + Graph.tot-pay.
       end.    
       
       /* sozdajem itogovuju stroku */
       find first Graph where Graph.month begins "KOP" no-error.
       if available Graph then do:
          &IF "{&OPSYS}" = "UNIX" &THEN
             Graph.pay-date     = ?.
          &ELSEIF "{&OPSYS}" = "WIN32" &THEN
             Graph.pay-date     = today.
          &ENDIF
          
          Graph.not-paied = tot-not-paied.
          Graph.cost-pay  = tot-cost-pay.
          Graph.prc-pay   = tot-prc-pay.
          Graph.atalg-pay = atal-s.
          Graph.pvn-pay   = tot-pvn-pay.
          Graph.tot-pay   = tot-tot-pay. 
          Graph.rate      = 0.
          Graph.prc-cost-pay = 0.
          release Graph.
       end.
 
       /* korrekcija PVN */
       sv-pvn-pay = (kopa-s - pirk-s) * lon-pvn / 100.
       if tot-pvn-pay < sv-pvn-pay then do:
          find last Graph where Graph.pvn-pay > 0 no-error.
          if available Graph then do:
             Graph.pvn-pay = Graph.pvn-pay + (sv-pvn-pay - tot-pvn-pay).
             release Graph.
          end.
       end.
       
       /* proverka pravilnosti rascheta */
       if sv-not-paied > 0 then do:
          bell.
          message "Остаток " sv-not-paied " после удаления не 0 !".
       end.

END PROCEDURE.
/*---------------------------------------------------------------*/

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE CreateGraphFile.
define input parameter mn            as integer. /* kolichestvo periodov */
define input parameter period        as integer. /* razmer perioda */
define input parameter rate          as decimal. /* procent */

def var irow as integer.
def var imon as integer.

def var nxt-dt     as date    no-undo.
def var wf-aval    as logical.
def var pr-sum     as integer.
def var pr-rate    as decimal.

for each Graph:
   delete Graph.
end.

wf-aval = no.
irow = 1.
imon = 0.
if rate = 0 then do:
   find first wf no-error.
   if available wf then do:
      pr-sum  = wf.nm.
      pr-rate = wf.rate.
   end.
   else do:
      pr-sum  = mn.
      pr-rate = rate.
   end.
end.   

find lonhar where lonhar.lon = s-lon and lonhar.ln = 1 no-lock.
do transaction:
     /*-------------- oplata avansa ---------------*/
     create Graph.
     Graph.n = irow.
     Graph.month        = string(imon).
     Graph.pay-date     = lon.rdt.
     Graph.rate         = 0.
     Graph.fx-cost-pay  = no.
     Graph.fx-amt-pay   = no.
   
     irow = irow + 1.
     imon = imon + 1.
     release Graph.

       nxt-dt = v-dt.
       do while imon <= mn:
         /*--------------- ostalnie viplati --------------*/
         create Graph.
         Graph.n = irow.
         Graph.month     = string(imon).
         Graph.pay-date  = nxt-dt.
         if rate <> 0 then 
            Graph.rate      = rate.
         else do:
            if imon > pr-sum then do:
               do while imon > pr-sum and available wf:
                  find next wf no-error.
                  if available wf then do:
                     pr-sum  = pr-sum + wf.nm.
                     pr-rate = wf.rate.
                  end.
               end.
            end.
            Graph.rate = pr-rate.
         end.
         Graph.fx-cost-pay = no.
         Graph.fx-amt-pay  = no.
         
         irow = irow + 1.
         imon = imon + 1.
         run nxt-month(v-day,Graph.pay-date,period,output v-dt2).
         nxt-dt = v-dt2.
         release Graph.

       end.
       
       /* sozdajem itogovuju stroku */
       create Graph.
       Graph.n = irow.

       &IF "{&OPSYS}" = "UNIX" &THEN
           Graph.month        = "Всего". 
           Graph.pay-date     = ?.
       &ELSEIF "{&OPSYS}" = "WIN32" &THEN
           Graph.month        = "Всего".
           Graph.pay-date     = today.
       &ENDIF       
       
       Graph.not-paied    = 0.
       Graph.cost-pay     = 0.
       Graph.prc-pay      = 0.
       Graph.atalg-pay    = 0.
       Graph.pvn-pay      = 0.
       Graph.tot-pay      = 0. 
       Graph.rate         = 0.
       Graph.prc-cost-pay = 0.
       Graph.fx-cost-pay  = no.
       Graph.fx-amt-pay   = no.
       release Graph.

       if lonhar.rez-char[6] ne "" then do :
          do i = 1 to integer(num-entries(lonhar.rez-char[6]) / 2):
             find first Graph where Graph.month = 
                  entry(i + i - 1,lonhar.rez-char[6]) no-error.
             if available Graph then do:
                Graph.cost-pay    = decimal(entry(i + i,lonhar.rez-char[6])).
                Graph.fx-cost-pay = true.
             end.
          end.
       end.
       if lonhar.rez-char[9] ne "" then do :
          do i = 1 to integer(num-entries(lonhar.rez-char[9]) / 2):
             find first Graph where Graph.month = 
                  entry(i + i - 1,lonhar.rez-char[9]) no-error.
             if available Graph then do:
                Graph.not-paied   = decimal(entry(i + i,lonhar.rez-char[9])).
                Graph.fx-amt-pay  = true.
             end.
          end.
       end.
       
end.
END PROCEDURE.
/*---------------------------------------------------------------*/

&IF "{&OPSYS}" = "UNIX" &THEN

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE CheckSum.
define input parameter rGraph as recid. /* Graph file recid */

def buffer bGraph for Graph.
def var cost-pay-sum as deci init 0.

for each bGraph break by n:
   if recid(bGraph) <> rGraph then cost-pay-sum = cost-pay-sum + bGraph.cost-pay.
   else do:
      cost-pay-sum = cost-pay-sum + bGraph.cost-pay.
      leave.
   end.
end.

if cost-pay-sum <= kopa-s then return "true".
else do:
   message "Превышена сумма лизинга !". pause. 
   return  "false".
end.
END PROCEDURE.
/*---------------------------------------------------------------*/

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE CheckTotSum.
def var tot as deci init 0.

find first Graph where Graph.month begins "KOP" no-error.

if Graph.cost-pay <> kopa-s then do:
   message "Суммы графика и лизинга не совпадают !" view-as alert-box warning.
   return  "false".
end.
else return "true".
END PROCEDURE.
/*---------------------------------------------------------------*/

&ENDIF
