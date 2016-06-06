/* lnfacif.p
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
*/

/*
* lnfacif.p
* Программа редактирования файла facif.
*/
{mainhead.i LNFACIF}
{ s-liz.i "NEW" }

&SCOPED-DEFINE cHelpString "F2 - помощь "
&SCOPED-DEFINE glFacifDisplay1 " cFacifFacif cFacifName cFacifAddr cFacifTel1 cFacifTel2 cFacifFax cFacifBanka cFacifKonts cFacifFanrur cFacifPvnMaks cFacifVaditais cFacifVadUzvards cFacifGrUzvards "
define var slFalonTypeList as character init "" view-as selection-list
        scrollbar-vertical size 20 by 10.
def var n as integer init 0.

/*------- DEFINE BUTTONS ----------*/
define button btnNext     label "Следующий".
define button btnEdit     label "Редактир.".
define button btnAdd      label "Добавить ".
define button btnDelete   label " Удалить ".
define button btnQuit     label "  Выход  ".
define button btnOk       label "  Ok  "   auto-go.
define button btnCancel   label " Cancel " auto-endkey.

/******************** FORMS **************************/
form skip
     cFacifFacif format "x(6)"          label "Код.........."  
                 skip
     cFacifName  format "x(50)"         label "Продавец....." 
                      help {&cHelpString} skip
     cFacifAddr  format "x(50)"         label "Адрес........"
                 help {&cHelpString} skip
     cFacifTel1  format "(xxx)xxx-xxxx" label "Телефон......" 
                 help {&cHelpString} ","
     cFacifTel2  format "(xxx)xxx-xxxx" no-label
                 help {&cHelpString} skip
     cFacifFax   format "(xxx)xxx-xxxx" label "Факс........." 
                 help {&cHelpString} skip
     cFacifBanka format "x(50)"         label "Банк........." 
                      help {&cHelpString} skip
     cFacifKonts format "x(20)"         label "Счет........."
                 help {&cHelpString} skip
     cFacifFanrur  format "x(18)"       label "Регистрационное удостоверение" 
                      help {&cHelpString} skip
     cFacifPvnMaks format "x(15)"       label "Налоговый регистрационный Nr... "
                 help {&cHelpString} skip
     cFacifVaditais format "x(40)"      label "Должность руководителя.........."
                 help {&cHelpString} skip
     cFacifVadUzvards format "x(40)"    label "Фамилия руководителя...."
                 help {&cHelpString} skip
     cFacifGrUzvards  format "x(40)"    label "Фамилия бухгалтера......"
                 help {&cHelpString} skip(3)
                 
     btnNext  at 15  space(2)
     btnEdit   space(2)
     btnAdd    space(2)
     btnDelete space(2)
     btnQuit
     with side-label row 3 overlay centered title "Клиенты" 
     width 80  frame frmUpdInfo.

form slFalonTypeList at column 27 row 3
     with width 80 no-box row 3 no-labels 10 down frame frmTitleFrame.

     
/****************** TRIGGERS *************************/
ON DEFAULT-ACTION OF slFalonTypeList in frame frmTitleFrame
DO:
   hide frame frmTitleFrame no-pause.
   run GoToFacifType.
   view frame frmTitleFrame.
END.
ON GO OF slFalonTypeList in frame frmTitleFrame
DO:
   APPLY "ENDKEY" to frame frmTitleFrame.
END.

/******************* INITIALIZATION ******************/
n = 1.
slFalonTypeList = "".
do while cFalonTypeList[n] <> "":
   slFalonTypeList:add-last(trim(cFalonTypeList[n])) in frame frmTitleFrame.
   n = n + 1.
end.

/****************** MAIN LOGIC ***********************/
display slFalonTypeList with frame frmTitleFrame.
enable slFalonTypeList with frame frmTitleFrame.
wait-for END-ERROR, ENDKEY of frame frmTitleFrame.
hide frame frmTitleFrame no-pause.
pause 0.


/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE GoToFacifType:
/*define input parameter cInpFacifType as char.*/

def var iKeyPresed as integer init 0.
def var lEditFacif as logical init no.

def var fMessage   as char.
fMessage = "[ENTER]  -redi¦ёt  [F1] -saglab–t   [F4] -atcelt                             ".

/******************* INITIALIZATION ******************/     
iKeyPresed = 0.
lEditFacif = no.
     
/******************* TRIGGER *************************/
ON CHOOSE OF btnNext in frame frmUpdInfo
DO:
   iKeyPresed = 1.
END.
ON CHOOSE OF btnEdit in frame frmUpdInfo
DO:
   find first facif where facif.facif = trim(cFacifFacif) no-lock no-error.
   if available facif then 
      iKeyPresed = 2.
   else return no-apply.
END.
ON CHOOSE OF btnAdd in frame frmUpdInfo
DO:
   iKeyPresed = 3.
END.
ON CHOOSE OF btnDelete in frame frmUpdInfo
DO:
   find first facif where facif.facif = trim(cFacifFacif) no-lock no-error.
   if available facif then 
      iKeyPresed = 4.
   else return no-apply.   
END.
ON CHOOSE OF btnQuit in frame frmUpdInfo
DO:
   iKeyPresed = 0.
END.

ON HELP ANYWHERE /*OF cFacifFacif in frame frmUpdInfo*/
DO:
   run facifh.
   cFacifFacif = cgFacifFacif.
   find first facif where facif.facif = cgFacifFacif no-lock no-error.
   if available facif then do:
      {s-liz1.i}
      display "{&glFacifDisplay1}" with frame frmUpdInfo.
      lEditFacif = true.
   end.
END.

ON RETURN OF cFacifFacif in frame frmUpdInfo
DO:
   assign frame frmUpdInfo cFacifFacif.
   
   run DisplayFacif(cFacifFacif).
   if return-value <> "true" then return no-apply.
   if not lEditFacif then do:
      lEditFacif = true.
   end.
   else do:
      find first facif where facif.facif = trim(cFacifFacif) no-lock no-error.
      if available facif then do:
         APPLY "CHOOSE" TO btnEdit in frame frmUpdInfo.
         return.
      end.
   end.
   return no-apply.
END.

ON ANY-PRINTABLE,BACKSPACE OF cFacifFacif in frame frmUpdInfo
DO:
   lEditFacif = false.
END.

ON GO OF cFacifFacif in frame frmUpdInfo
DO:
   APPLY "CHOOSE" TO btnQuit in frame frmUpdInfo.
END.


/******************* MAIN LOGIC **********************/
hide message no-pause.
message color normal fMessage.
  
run DisplayFacif(cFacifFacif).
disable all with frame frmUpdInfo.
enable cFacifFacif
       btnNext
       btnEdit
       btnAdd
       btnDelete
       btnQuit
       with frame frmUpdInfo.
wait-for CHOOSE of btnNext,btnEdit,btnAdd,btnDelete,btnQuit OR 
         END-ERROR,ENDKEY  of frame frmUpdInfo focus cFacifFacif.

hide frame frmUpdInfo no-pause.
pause 0.
hide message no-pause.

case iKeyPresed:
   when 1 then do: cFacifFacif   = "".
                   run FacifClear. 
                   run GoToFacifType. 
               end.
   when 2 then do: run UpdateFacif("edit").
                   run GoToFacifType.
               end.
   when 3 then do: run FacifClear.
                   run lnfacifn.
                   cFacifFacif = cgFacifFacif.
                   run UpdateFacif("add").
                   run GoToFacifType.
               end.
   when 4 then do: run DeleteFacif.
                   run FacifClear.
                   run GoToFacifType.
               end.
end case.

END PROCEDURE.
/*-------------------------------------------------------------*/

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE UpdateFacif:
define input parameter cEditType as char.

if cEditType = "" then cEditType = "edit".

ON RETURN OF cFacifFanrur in frame frmUpdInfo
DO:
  assign frame frmUpdInfo cFacifFanrur.
  find first facif where facif.fanrur = trim(cFacifFanrur) no-lock no-error.
  if available facif and cEditType = "add" then do:
     message "Запись с кодом " trim(cFacifFanrur) " есть в базе данных !".            pause.
     return no-apply.
  end.
END.

display "{&glFacifDisplay1}" with frame frmUpdInfo.
pause 0.
disable all with frame frmUpdInfo.
enable cFacifName cFacifAddr cFacifTel1
cFacifTel2 cFacifFax cFacifBanka cFacifKonts cFacifFanrur cFacifPvnMaks 
cFacifVaditais cFacifVadUzvards cFacifGrUzvards with frame frmUpdInfo.

disable cFacifFacif with frame frmUpdInfo.
do on error undo, retry on endkey undo,leave:
   wait-for GO,END-ERROR,ENDKEY of frame frmUpdInfo focus cFacifName.
end.

if keyfunction(lastkey) <> "ENDKEY" and keyfunction(lastkey) <> "END-ERROR"
then do transaction:
   if cEditType = "add" then do:
      create facif.
      facif.facif  = cFacifFacif.
      facif.fanrur = cFacifFanrur.
   end.
   assign frame frmUpdInfo cFacifFacif cFacifName cFacifAddr cFacifTel1
   cFacifTel2 cFacifFax cFacifBanka cFacifKonts cFacifFanrur cFacifPvnMaks
   cFacifVaditais cFacifVadUzvards cFacifGrUzvards.
   find first facif where facif.facif = cFacifFacif exclusive-lock no-error.
   if available facif then do:
      assign
      facif.facif       = cFacifFacif
      facif.name        = cFacifName
      facif.addr[1]     = cFacifAddr
      facif.tel         = trim(cFacifTel1) + "," + trim(cFacifTel2)
      facif.fax[1]      = cFacifFax
      facif.banka       = cFacifBanka
      facif.konts       = cFacifKonts
      facif.fanrur      = cFacifFanrur
      facif.rez-char[1] = cFacifPvnMaks 
      facif.vad-amats   = cFacifVaditais
      facif.vad-vards   = cFacifVadUzvards
      facif.gal-gram    = cFacifGrUzvards
      no-error.
   end.
   if error-status:error then do:
      message error-status:get-message(error-status:num-messages). 
      pause. 
   end.
   release facif.
end.
else do:  /* endkey */
   cFacifFacif = "".
end.

hide frame frmUpdInfo no-pause.
pause 0.
hide message no-pause.
END PROCEDURE.
/*----------------------------------------------------------------*/

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE DeleteFacif:
define variable lAnswer as logical init no.
display "{&glFacifDisplay1}" with frame frmUpdInfo.
find first facif where facif.facif = cFacifFacif exclusive-lock no-error.
if available facif then do:
   lAnswer = no.
   message "Вы действительно хотите удалить запись ?" VIEW-AS ALERT-BOX
   QUESTION BUTTONS YES-NO TITLE "" UPDATE lAnswer.
   if lAnswer then do:
      delete facif.
      cFacifFacif = "".
   end.
end.

hide frame frmUpdInfo no-pause.
pause 0.
hide message no-pause.
END PROCEDURE.
/*----------------------------------------------------------------*/

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE FacifClear:
/*cFacifFacif   = "".*/
cFacifName       = "".
cFacifAddr       = "".
cFacifTel1       = "".
cFacifTel2       = "".
cFacifFax        = "".
cFacifBanka      = "".
cFacifKonts      = "".
cFacifFanrur     = "".
cFacifPvnMaks    = "".
cFacifVaditais   = "".
cFacifVadUzvards = "".
cFacifGrUzvards  = "".
display "{&glFacifDisplay1}" with frame frmUpdInfo.
pause 0.
END PROCEDURE.
/*----------------------------------------------------------------*/

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
PROCEDURE DisplayFacif:
define input parameter cFacifFacifParam as char.

if cFacifFacifParam = "" then do:
   run FacifClear.
   return "false".
end.
find first facif where facif.facif = cFacifFacifParam no-lock no-error.
if not available facif then do:
   message "Записи нет в базе данных!".
   pause no-message.
   hide message no-pause.
   run FacifClear.
   return "false".
end.

{s-liz1.i}

display "{&glFacifDisplay1}" with frame frmUpdInfo.
pause 0.
return "true".
END PROCEDURE.
/*----------------------------------------------------------------*/
