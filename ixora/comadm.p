/* comadm.p
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
 * BASES
        BANK COMM
 * AUTHOR
        26/03/09 id00205
        13.10.2010 k.gitalov перекомпиляция
 * CHANGES
        14.11.2012 damir - Контроль отправки платежей (вручную или автоматически). Variable - v-SolveLogi.

*/

{global.i}

def var apbal as deci init 0.
def var minbal as deci init 0.
def var runserv as log init no.
def var v-Solve as inte. /*1-да,2-нет*/
def var v-SolveLogi as logi format "Разрешена/Запрещена".
def var apbal_time as char init "".
def var e-mail as char format "x(34)" extent 9.
def var apbal_date as date.
def var ListType as char format "x(20)" VIEW-AS COMBO-BOX LIST-ITEMS "Разрешен", "Запрещен".
def var IntType as int init 1.
define button b0 label "Изменить".
define button b1 label "Сохранить".
define button b2 label "Выход".
define button b3 label "Провайдеры".
define button b4 label "Комиссия".
def var rez as log.
def var i as int.


/************************************************************************************/
 DEFINE FRAME MainFrame
         skip
         "Баланс на " apbal_date no-label apbal_time no-label " " apbal format "z,zzz,zzz.99" no-label  skip (1)
         "Минимальный остаток   :" minbal format "z,zzz,zzz.99" no-label skip (1)
         "Адреса для уведомлений:" skip e-mail VIEW-AS FILL-IN  /*EDITOR SIZE 35 BY 1 */ no-label skip (1)
         "Отпр. платежа в Аван.Плат менеджером : " v-SolveLogi no-label help "Нажмите клавишу <Р> - Разрешена, <З> - Запрещена" skip(1)
         "Статус приема         :" ListType no-label skip (1)
         "__________________________________________________________" skip (1)
         space (2) b3 b4 b0 b1 b2 skip
  WITH SIDE-LABELS centered overlay row 10 WIDTH 70 TITLE "Настройка Авангард-Plat" .


 ON RETURN, VALUE-CHANGED OF ListType
 DO:
   IntType = SELF:LOOKUP(SELF:SCREEN-VALUE) no-error.
   if IntType = 1 then  runserv = yes.
   else runserv = no.
   APPLY "GO" TO ListType IN FRAME MainFrame.
 END.
/**********************************************************************/
 on choose of b0 in frame MainFrame do:
   disable b0 with frame MainFrame.
   enable b1 b2  with frame MainFrame.
   update minbal e-mail v-SolveLogi ListType with frame MainFrame.
 end.
/**********************************************************************/
on choose of b3 in frame MainFrame do:
  def var i-p as int.
  def var l-p as log init no.
  do i-p = 1 to 9:
     if e-mail[i-p] begins(g-ofc) then
     do:
      l-p = Yes.
     end.
  end.

  if l-p then do:
    hide frame MainFrame.
    run provadm ("1").
    run ShowFrame.
  end.
  else message "Вы не можете редактировать данные провайдеров!" view-as alert-box.
end.
/**********************************************************************/
on choose of b4 in frame MainFrame do:
  hide frame MainFrame.
  run provpay.
  run ShowFrame.
end.
/**********************************************************************/
 on choose of b1 in frame MainFrame do:
   run yn("","Сохранить изменения?","","", output rez).
   if rez then
   do:
      APPLY "GO" TO  FRAME MainFrame.
      if v-SolveLogi then v-Solve = 1. else v-Solve = 2.
      find first comm.pksysc where comm.pksysc.sysc = "comadm" exclusive-lock no-error.
      if avail comm.pksysc then
      do:
        comm.pksysc.loval = runserv.
        comm.pksysc.inval = v-Solve.
        comm.pksysc.deval = minbal.
        comm.pksysc.chval = "".
        repeat i=1 to 8:
         if trim(e-mail[i]) <> "" then do: comm.pksysc.chval = comm.pksysc.chval + trim(e-mail[i]) + ";". end.
        end.
      end.

      find current comm.pksysc no-lock no-error.

     /* apply "endkey" to frame MainFrame.*/

   end.
   else do: run ShowFrame. undo. end.

 end.
/**********************************************************************/
 on choose of b2 in frame MainFrame do:
   apply "endkey" to frame MainFrame.
 end.
/**********************************************************************/

  run ShowFrame.
  enable b2 b0 b4 b3 with frame MainFrame.


  WAIT-FOR endkey of frame MainFrame.
  hide frame MainFrame.
/*********************************************************************************************/
procedure ShowFrame:
  def var i as int.
  def var c as int.
  find first comm.pksysc where comm.pksysc.credtype = '0' and comm.pksysc.sysc = "apbal" no-lock no-error.
  if avail comm.pksysc then
  do:
    apbal_time = string(comm.pksysc.inval,"HH:MM:SS").
    apbal_date = comm.pksysc.daval.
    apbal      = comm.pksysc.deval.
  end.

  find first comm.pksysc where comm.pksysc.sysc = "comadm" no-lock no-error.
  if avail comm.pksysc then
  do:
    runserv =  comm.pksysc.loval.
    v-Solve =  comm.pksysc.inval.
    minbal  =  comm.pksysc.deval.
    c = num-entries(comm.pksysc.chval,";").
    if c > 0 then
    do:
      do i = 1 to c:
        e-mail[i]  =  entry(i,comm.pksysc.chval,";").
      end.
    end.
    else e-mail[1] = trim(comm.pksysc.chval).
  end.

  if v-Solve = 1 then v-SolveLogi = yes.
  else v-SolveLogi = no.

  if runserv then IntType = 1.
  else IntType = 2.
  ListType:SCREEN-VALUE IN frame MainFrame = ListType:ENTRY(IntType).

  DISPLAY apbal_date apbal_time apbal minbal ListType v-SolveLogi e-mail b0 b1 b2 WITH  FRAME MainFrame.

end procedure.
/*********************************************************************************************/
