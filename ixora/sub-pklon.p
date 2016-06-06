/* sub-pklon.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Редактирование признаков для кредитов
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
        04/08/2009 galina
 * BASES
        BANK
 * CHANGES
   скопировала из subcodl.p с небольшими изменениями
        29.03.2012 Lyubov - добавила параметр при вызове процедуры p-codific
*/





/* h-quetyp.p */
  {global.i}
/*
  {ps-prmt.i}
*/
  def var h as int no-undo.
  def var i as int no-undo.
  def var d as int no-undo.

  def var v-codname like sub-cod.rcode no-undo.
  def input parameter v-acc like aaa.aaa .
  def input parameter v-sub like gl.sub .
  def input parameter v-dcod as char.

  def var yn as log init false .
  def var v-from as cha format "x(1)" .
  def buffer b-sub for sub-cod .
  def var dicname as cha no-undo.
  def var codname as cha no-undo.
  def new shared var v-code like codfr.code .
  def new shared var v-d-cod like codfr.codfr .

  def var v-old as int init 0 .
  h = 13 .
  d = 60.

  do:
    {browpnpj.i
        &h = "h"
        &form = "browform2.i"
        &first = " for each sub-dic where sub-dic.sub = v-sub and sub-dic.d-cod begins v-dcod no-lock .
         find first sub-cod where sub-cod.acc = v-acc and sub-cod.sub = v-sub and sub-cod.d-cod = sub-dic.d-cod use-index dcod no-lock no-error .
         if not avail sub-cod then do transact:
           create sub-cod.
           assign
           sub-cod.acc = v-acc
           sub-cod.sub = v-sub
           sub-cod.d-cod = sub-dic.d-cod
           sub-cod.ccode = 'msc'
           cur = recid(sub-cod).
          end.
         end.
        if v-sub = 'LON' then run ln_sub_pre.
        form  v-codname label 'Значение' with side-label overlay centered row 10 frame vvv.
        form  dicname format 'x(50)' with no-label centered row 18 frame dop .
        form  ' < Пробел > - изменить F10 - удалить < Enter > - ручной ввод '
        with no-label centered row 21 no-box frame ddd ."
        &where = " sub-cod.acc = v-acc
        and sub-cod.sub = v-sub and sub-cod.d-cod begins v-dcod  use-index dcod "
        &frame-phrase = "row 1 centered scroll 1 h down overlay
         title v-acc + ' ' + v-sub "
        &predisp =
        " view frame ddd .    dicname = '' . codname = '' .
         find first codific where codific.codfr = sub-cod.d-cod no-lock no-error.
         if avail codific then dicname = codific.name .
         if rcode ne '' then codname = rcode . else do:
         find first codfr where codfr.codfr = codific.codfr and
          codfr.code = sub-cod.ccode no-lock no-error.
         if avail codfr then codname = codfr.name[1] .
         end.
         if sub-cod.rcode ne '' then v-from = 'R' . else
         v-from = 'S' .
        display dicname with frame dop  .
        v-old = cur . "
        &seldisp = " sub-cod.ccode "
        &file = " sub-cod "
        &disp = " sub-cod.d-cod sub-cod.ccode codname v-from "
        &postupd = "if rcode ne '' or
         (rcode = '' and codname = ''  )
         then do:
          v-codname = rcode.
          update v-codname with frame vvv.
          rcode = v-codname.
          hide frame vvv.
         end."
        &poscreat = " sub-cod.sub = v-sub.
                      sub-cod.acc = v-acc.
                      run addcod.
           if not keyfunction(lastkey) = 'end-error'  then
           do:
            find current sub-cod exclusive-lock no-error  .
            if avail sub-cod and sub-cod.d-cod = ''
             then do: delete sub-cod  .
             cur = v-old .
             end. else cur = recid(sub-cod) .
           end.
           "
        &addupd = " "
        &postadd = "
        leave . "
        &enderr = "if keyfunction(lastkey) = 'end-error' and v-sub = 'LON' then run ln_sub_post.
         curold = cur . find first sub-cod where   sub-cod.acc = v-acc and
         sub-cod.sub = v-sub and  sub-cod.ccode eq '' use-index dcod  no-lock no-error .
         if avail sub-cod then do: yn = false .
         Message 'Не все коды введены ! Выход ?' update yn .
         if yn then do: for each sub-cod where sub-cod.acc = v-acc and sub-cod.sub = v-sub and sub-cod.ccode eq '' use-index dcod .
         delete sub-cod . end . end.
         else do: cur = curold . leave . end.
         end. hide frame vvv. hide frame frm . hide frame dop. hide frame ddd."
        &addcon = "false "
        &updcon = "true  "
        &delcon = "true"
        &retcon = "false"
        &befret = "  "
        &action = " if keylabel(lastkey) = ' ' then do: v-d-cod = sub-cod.d-cod.
                       run p-codific(codific.codfr,'*',output v-code). if v-code ne '' and v-code
                       ne sub-cod.ccode then do : yn = no. message 'ИЗМЕНЕНИЕ КОДА. СТАРЫЙ ' + sub-cod.ccode + ' НОВЫЙ ' + v-code
                          view-as alert-box button yes-no update yn . if yn then do :
                             find current sub-cod exclusive-lock . sub-cod.ccode = v-code . sub-cod.rcode = '' .
                          end. find current sub-cod no-lock . end. end."
       }
  end.


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
           find current sub-cod no-lock .
           end.
          end.
          return .
  end procedure .



procedure ln_sub_pre.
  define var v-subcod as char.

  find first lon where lon.lon = v-acc no-lock no-error.
  find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = lon.cif and sub-cod.d-cod = 'ecdivis' no-error.
  if available sub-cod then do:
     v-subcod = sub-cod.ccode.
     find sub-cod where sub-cod.sub eq "LON" and sub-cod.acc eq v-acc and sub-cod.d-cod = 'ecdivis' no-error.
     assign sub-cod.rdt = g-today
            sub-cod.ccode = v-subcod.
  end.
  find sub-cod where sub-cod.sub eq "LON" and sub-cod.acc eq v-acc and sub-cod.d-cod = 'flagl' no-error .
  if sub-cod.ccode = 'msc' then       /*---22/02/06 NatalyaD.*/
  assign sub-cod.rdt = g-today
         sub-cod.ccode = '02'.
  find sub-cod where sub-cod.sub eq "LON" and sub-cod.acc eq v-acc and sub-cod.d-cod = 'lnpen' no-error .
  if sub-cod.ccode = 'msc' then
  assign sub-cod.rdt = g-today
         sub-cod.ccode = '02'.
end procedure.


procedure ln_sub_post.
  define buffer b-subcod for sub-cod.

  def var dn1 as integer.
  def var dn2 as deci.

  find sub-cod where sub-cod.sub eq "LON" and sub-cod.acc eq v-acc and sub-cod.d-cod = 'lnshifr' no-error.
  find first lon where lon.lon = v-acc no-lock no-error.

  run day-360(lon.rdt,lon.duedt - 1,lon.basedy,output dn1,output dn2).

  find b-subcod where b-subcod.sub = 'LON' and b-subcod.acc eq v-acc  and b-subcod.d-cod = 'lneko' no-error .
  if available b-subcod then do:
    if b-subcod.ccode = '71' or b-subcod.ccode = '92' then do:
       find b-subcod where b-subcod.sub = 'cln' and b-subcod.acc = lon.cif and b-subcod.d-cod = 'ecdivis' no-error .
       if avail b-subcod then do:
          if b-subcod.ccode = '98' then do:
             if lon.crc = 1 then do:
                if dn1 <= lon.basedy then assign sub-cod.ccode = '05' sub-cod.rdt = g-today.
                                     else assign sub-cod.ccode = '06' sub-cod.rdt = g-today.
             end.
             else do:
                if dn1 <= lon.basedy then assign sub-cod.ccode = '13' sub-cod.rdt = g-today.
                                     else assign sub-cod.ccode = '14' sub-cod.rdt = g-today.
             end.
          end.
          else do:
             if lon.crc = 1 then do:
                if dn1 <= lon.basedy then assign sub-cod.ccode = '01' sub-cod.rdt = g-today.
                                     else assign sub-cod.ccode = '02' sub-cod.rdt = g-today.
             end.
             else do:
                if dn1 <= lon.basedy then assign sub-cod.ccode = '09' sub-cod.rdt = g-today.
                                     else assign sub-cod.ccode = '10' sub-cod.rdt = g-today.
             end.
          end.
       end.
    end.
    if b-subcod.ccode begins '72' then do:
       find b-subcod where b-subcod.sub = 'cln' and b-subcod.acc = lon.cif and b-subcod.d-cod = 'ecdivis' no-error.
       if avail b-subcod then do:
          if b-subcod.ccode = '98' then do:
             if lon.crc = 1 then do:
                if dn1 <= lon.basedy then assign sub-cod.ccode = '07' sub-cod.rdt = g-today.
                                     else assign sub-cod.ccode = '08' sub-cod.rdt = g-today.
             end.
             else do:
                if dn1 <= lon.basedy then assign sub-cod.ccode = '15' sub-cod.rdt = g-today.
                                     else assign sub-cod.ccode = '16' sub-cod.rdt = g-today.
             end.
          end.
          else do:
             if lon.crc = 1 then do:
                if dn1 <= lon.basedy then assign sub-cod.ccode = '03' sub-cod.rdt = g-today.
                                     else assign sub-cod.ccode = '04' sub-cod.rdt = g-today.
             end.
             else do:
                if dn1 <= lon.basedy then assign sub-cod.ccode = '11' sub-cod.rdt = g-today.
                                     else assign sub-cod.ccode = '12' sub-cod.rdt = g-today.
             end.
          end.
       end.
    end.
  end.
  find sub-cod where sub-cod.sub eq 'LON' and sub-cod.acc eq v-acc and sub-cod.d-cod = 'kdkik' no-error.
  if sub-cod.ccode <> 'msc' then do:
     find trxbal where trxbal.subled = 'LON' and trxbal.acc = v-acc and trxbal.lev = 1 no-lock no-error.
     if  abs(trxbal.dam - trxbal.cam) > 0 then do:
     message 'Кредит не выкуплен!' skip 'Признак kdkik не может быть изменён.' view-as alert-box title 'ВНИМАНИЕ!'.
     sub-cod.ccode = 'msc'.
     end.
  end.
end procedure.
