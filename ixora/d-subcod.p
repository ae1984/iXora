 /* d-subcod.p
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
        BANK
 * AUTHOR
        18.09.2006 u00600 - автоматическое проставление реквизитов для п.8.3.3 - дебиторы
 * CHANGES
        28/05/08 marinav
        01/04/2011 madiyar - изменился справочник pdoctng, исправил инициализацию значения справочника
        29.03.2012 Lyubov - добавила параметр при вызове процедуры p-codific

*/

/* h-quetyp.p */
  {global.i}
  {codcondit.i} /* функция проверки введенного значения для отсечения части кодов справочника */

/*
  {ps-prmt.i}
*/
  def var h as int .
  def var i as int .
  def var d as int .

  def var v-codname like sub-cod.rcode  format 'x(45)'.
  def input parameter v-acc like aaa.aaa .
  def input parameter v-sub like gl.sub .

  def var v-rez like sub-cod.rcode .

  def var yn as log init false .

/*   def var v-acc like aaa.aaa init "RMZ622981A" .
   def var v-sub like gl.sub  init "rmz" .
  */
  def var v-from as cha format "x(1)" .
  def buffer b-sub for sub-cod .
  def var dicname as cha .
  def var codname as cha .
  def new shared var v-code like codfr.code .
  def new shared var v-d-cod like codfr.codfr .
  def var v-old as int init 0 .
  def var errormess as char.
  def var bilance   as decimal format '->,>>>,>>>,>>9.99'.

def shared var v-grp like debgrp.grp.
def shared var v-ls like debls.ls.
def var rem_u as logi init false no-undo.

if v-grp ne 0 and v-ls ne 0 then rem_u = true.

  h = 13 .
  d = 60.

  do:
    {browpnpj.i &h = "h"
&form = "browform.i"
&first = " do transact: run fnew .
            form  v-codname label 'Значение' with side-label overlay centered row 10 frame vvv.
                form  dicname format 'x(50)' with no-label centered row 18 frame dop.
                form  ' < Пробел > - изменить F10 - удалить < Enter > - ручной ввод ' with no-label centered row 21 no-box frame ddd .
        end. "
&where = " sub-cod.acc = v-acc and sub-cod.sub = v-sub use-index dcod "
&frame-phrase = "row 1 centered scroll 1 h down overlay title v-acc + ' ' + v-sub "
&predisp = " view frame ddd. dicname = ''. codname = ''.
    find first codific where codific.codfr = sub-cod.d-cod no-lock   no-error.
    if avail codific then dicname = codific.name .
    find first codfr where codfr.codfr = codific.codfr and codfr.code = sub-cod.ccode  no-lock no-error.
    if rcode ne '' or substr(codfr.name[1],1,3) eq '#$%' then codname = rcode .
    else do: codname = codfr.name[1]. end.
    if substr(codfr.name[1],1,3) = '#$%' then v-from = 'P'.
    else if sub-cod.rcode = '' then v-from = 'S'. else  v-from = 'R' .
    display dicname with frame dop  . v-old = cur . "
&seldisp = " sub-cod.ccode "
&file = " sub-cod "
&disp = " sub-cod.d-cod sub-cod.ccode codname sub-cod.rdt v-from "
&postupd = " if (rcode ne '' and codfr.name[1] = '') or (rcode = '' and codfr.name[1] = '') then do: v-codname = rcode.  update v-codname with frame vvv.
     rcode = v-codname.  for each loncon where loncon.cif = v-acc. run atl-dat (loncon.lon,g-today,output bilance). /* остаток  ОД*/
     if bilance > 0 then do: if sub-cod.d-cod = 'clnbk' then loncon.galv-gram = v-codname. if sub-cod.d-cod = 'clnchf' then loncon.vad-vards = v-codname.
     end. end. hide frame vvv. if sub-cod.d-cod = 'clnchf' or sub-cod.d-cod = 'clnbk' then run fngrchief(input sub-cod.acc, input sub-cod.d-cod). end.
	else if (rcode ne '' and substr(codfr.name[1],1,3) = '#$%' ) or (rcode = '' and substr(codfr.name[1],1,3) = '#$%' ) then do : v-rez = sub-cod.rcod . run value(substr(codfr.name[1],4))(input-output v-rez).
	if v-rez ne '' then do : rcode = v-rez. sub-cod.rdt = g-today . find first codfr where codfr.codfr = codific.codfr and
         codfr.code = sub-cod.ccode  exclusive-lock no-error. codfr.code = codfr.codfr. release codfr. end. end. else run addpro .
    if avail sub-cod and sub-cod.sub = 'cln' and sub-cod.d-cod = 'scann' then do: if sub-cod.ccode = 't' and sub-cod.rcode = '' then sub-cod.rcode = 'Сканирование,' + string(g-today ). else if sub-cod.ccode <> 't' then sub-cod.rcode = ''. end. "
&poscreat = " sub-cod.sub = v-sub. sub-cod.acc = v-acc. run addcod. if not keyfunction(lastkey) = 'end-error'  then do:
       find current sub-cod exclusive-lock no-error. if avail sub-cod and sub-cod.d-cod = '' then do: delete sub-cod. cur = v-old.
       end. else cur = recid(sub-cod). end. "
&addupd = " "
&postadd = " leave. "
&enderr = " curold = cur . find first sub-cod where sub-cod.acc = v-acc and
   sub-cod.sub = v-sub and  sub-cod.ccode eq '' use-index dcod no-lock no-error.
   if avail sub-cod then do:
     yn = false . Message 'Не все коды введены ! Выход ?' update yn .
   if yn then do:
     for each sub-cod where sub-cod.acc = v-acc and sub-cod.sub = v-sub
     and sub-cod.ccode eq '' use-index dcod. delete sub-cod. end. end.
     else do: cur = curold . leave . end. end.
    hide frame vvv. hide frame frm . hide frame dop. hide frame ddd."
&addcon = "false"
&preupdcondition = "preupdcondition.i"
&updcon = "true"
&delcon = "true"
&retcon = "false"
&befret = " "
&action = " if keylabel(lastkey) = ' ' then
  if v-from = 'S' then do: v-d-cod = sub-cod.d-cod. if rem_u and v-d-cod = 'pdoctng' then v-code = '01' . else run p-codific(codific.codfr,'*',output v-code).
    view frame frm. pause 0.
    if v-code ne '' and v-code ne sub-cod.ccode then do :
      run subfor. find current sub-cod no-lock. end. end." }

end.

/*   PROCEDURE SUBFOR  */
  procedure subfor.
    def var emess as char.
    def var v-bool as logi.

      if not isvalidcod(v-code, output emess) then do:
        message emess. pause. leave.
      end.

      find current sub-cod exclusive-lock.

      sub-cod.ccode = v-code.
      sub-cod.rdt = g-today .

      find first codfr where codfr.codfr = sub-cod.d-cod and
      codfr.code = v-code  no-lock no-error.
      if substr(codfr.name[1],1,3) = '#$%' then
      do:

/*u00600*/

if rem_u = true then do:
find first debls where debls.grp = v-grp and debls.ls = v-ls no-lock no-error.
if avail debls then v-rez = '14,' + debls.kbe + ','.
end.
else  v-rez = ' , ,'.

       run value(substr(codfr.name[1],4))(input-output v-rez).
       if v-rez ne ''  then do: rcode = v-rez.   sub-cod.rdt = g-today . end.
       else sub-cod.rcode = ''.
      end.
      else sub-cod.rcode = ''. /* sub-cod.rwho = g-ofc. */

      if avail sub-cod and sub-cod.sub = 'cln' and sub-cod.d-cod = 'scann' then do:
         if v-code = 't' and sub-cod.rcode = '' then sub-cod.rcode = 'Сканирование,' + string(g-today ).
         else if v-code <> 't' then sub-cod.rcode = ''.
      end.

end procedure.

/*   PROCEDURE ADDCOD  */
  procedure addcod .
          v-code = '' . v-d-cod = sub-cod.d-cod  .
          run h-ccode.
          if v-code ne '' and v-d-cod ne '' then do:
           find first b-sub where b-sub.acc = v-acc
            and b-sub.sub = v-sub and
            b-sub.d-cod = v-d-cod
            use-index dcod
            no-lock no-error .
           if avail b-sub and recid(b-sub)
             ne recid(sub-cod) then
           do :
            repeat :
            Message " Справочник уже используется ". pause .
            leave .
            end.
           end.
           else
           do:
           find current sub-cod exclusive-lock .
           sub-cod.ccode = v-code .
           sub-cod.d-cod = v-d-cod .
           sub-cod.rdt = g-today .
           find current sub-cod no-lock .
           end.
          end.
          return .
  end procedure .


/*   PROCEDURE ADDPRO  */
 procedure addpro .

  find current sub-cod exclusive-lock .

  repeat on error undo,retry :
   update sub-cod.ccode with frame frm .

   sub-cod.rdt = g-today .
   find first codfr where codfr.codfr = sub-cod.d-cod
   and codfr.code = sub-cod.ccode use-index cdco_idx no-lock no-error .
   if avail codfr then leave . else undo,retry .
  end. end.


procedure fnew.

 for each sub-dic where sub-dic.sub = v-sub no-lock .
         find first sub-cod where sub-cod.acc = v-acc and sub-cod.sub = v-sub and sub-cod.d-cod = sub-dic.d-cod use-index dcod  no-lock no-error.
         if not avail sub-cod then do transact:
          create sub-cod.
          sub-cod.acc = v-acc.
          sub-cod.sub = v-sub.
          sub-cod.d-cod = sub-dic.d-cod.

          if sub-dic.d-cod = "urgency" then
             sub-cod.ccode = 'o'.
          else
             sub-cod.ccode = 'msc'.

          cur = recid(sub-cod).
          end.
 end.
end procedure.
