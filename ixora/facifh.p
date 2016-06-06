/* facifh.p
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
*  facifh.p
*  Программа помощи по файлу facif 
*/
{ s-liz.i }

/***************** DEFINE VARIABLE **********************/
def var cFacifTypedName as char.
def var rFacif          as rowid.

/***************** DEFINE QUERY *************************/
define query qryFacif for facif.

/***************** DEFINE BROWSE ************************/
define browse brwFacif query qryFacif no-lock
       display facif.name    format "x(30)" 
               facif.facif   format "x(7)"
       with 11 down width 42 no-labels.
       
form cFacifTypedName format "x(30)" label "Наименование" skip(1)
     brwFacif
     with row 4 overlay centered side-labels frame frmFacifSearch.
     

/******************* TRIGGERS   *************************/
ON ANY-PRINTABLE,BACKSPACE OF cFacifTypedName
DO:
   APPLY LAST-EVENT:FUNCTION TO SELF.
   ASSIGN cFacifTypedName.

   find first facif where facif.name begins trim(cFacifTypedName) 
   no-lock no-error.   
   if available facif then do:
      reposition qryFacif to rowid rowid(facif) no-error.
   end.
   RETURN NO-APPLY.
END.
ON RETURN OF cFacifTypedName
DO:
   find first facif where facif.name begins trim(cFacifTypedName) 
   no-lock no-error.   
   if available facif then do:
      APPLY "DEFAULT-ACTION" to brwFacif.
   end.
   else return no-apply.
END.

/******************* MAIN LOGIC *************************/
cFacifTypedName = "".
open query qryFacif for each facif no-lock by facif.name.
do on endkey undo,leave:
   display cFacifTypedName brwFacif with frame frmFacifSearch.
   enable cFacifTypedName brwFacif with frame frmFacifSearch.
   wait-for DEFAULT-ACTION,ENDKEY,END-ERROR of brwFacif 
   in frame frmFacifSearch focus cFacifTypedName.
end.
hide frame frmFacifSearch no-pause.
pause 0.
if keyfunction(lastkey) <> "ENDKEY" and keyfunction(lastkey) <> "END-ERROR"
then do:
   if available facif then do: 
      cgFacifFacif    = facif.facif.
      cgFacifFacifApd = facif.facif.
   end.
end.
