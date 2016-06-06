/* cif-prn.p
 * MODULE
        Клиентская база
 * DESCRIPTION
        Редактирование признака клиента "Печатать/нет сторнированные проводки"
        сам признак лежит в sub-cod, но справочник не подвязан к сабледжеру cif, поэтому не виден в пункте Справ
 * RUN
        верхнее меню
 * CALLER
        cifedt.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-2
 * AUTHOR
        19.09.2003 nadejda
 * CHANGES
*/                                        

{global.i}

define shared variable s-cif like cif.cif.

def var v-codfr as char init "clnprn".
def var v-sub   as char init "vip".

define variable v-code as char format "x(15)".
define variable v-des1 as char format "x(30)".
define variable v-des2 as char format "x(30)".
define variable v-des3 as char format "x(30)".
define variable v-des4 as char format "x(30)".
define variable v-des5 as char format "x(30)".

def var v-str as char.
def var v-str1 as char.
def var i as integer.

function chkcode returns logical (p-value as char).
  def var ii as integer.

  if p-value = "" then return true.

  do ii = 1 to num-entries (p-value):
    if not can-find (first codfr where codfr.codfr = v-codfr and codfr.code = entry(ii, p-value) no-lock) then return false.
  end.    

  return true.
end.

form
  v-code label " ПЕЧАТЬ ПРОВОДОК "
    help " Настройка печати проводок в выписке по счету (F2 - выбор)"
    validate (chkcode(v-code), " Нет такого кода настройки печати!")
  skip
  " >> " at 14 v-des1 no-label at 20 skip
  " >> " at 14 v-des2 no-label at 20 skip
  " >> " at 14 v-des3 no-label at 20 skip
  " >> " at 14 v-des4 no-label at 20 skip
  " >> " at 14 v-des5 no-label at 20 skip

  with row 5 centered overlay side-labels title " ПАРАМЕТРЫ ПЕЧАТИ ВЫПИСОК " frame f-edt.

on help of v-code in frame f-edt do:
  run uni_help.p (v-codfr, "*", output v-code).
  displ v-code with frame f-edt. 
end.

find cif where cif.cif = s-cif no-lock no-error.
if not available cif then return.

on "value-changed" of v-code in frame f-edt do:
  v-str = v-code:screen-value.

  do i = 1 to 5:
    if i <= num-entries (v-str) then do:
      find first codfr where codfr.codfr = v-codfr and codfr.code = entry (i, v-str) no-lock no-error.
      if available codfr then v-str1 = codfr.name[1].
                         else v-str1 = "".
    end.
    else v-str1 = "".

    case i :
      when 1 then v-des1:screen-value = v-str1.
      when 2 then v-des2:screen-value = v-str1.
      when 3 then v-des3:screen-value = v-str1.
      when 4 then v-des4:screen-value = v-str1.
      when 5 then v-des5:screen-value = v-str1.
    end case.
  end.
end.

find sub-cod where sub-cod.sub = v-sub and sub-cod.d-cod = v-codfr and sub-cod.acc = s-cif no-lock no-error.
if avail sub-cod then v-code = sub-cod.ccode.

displ v-code with frame f-edt.
apply "value-changed" to v-code in frame f-edt.

update v-code with frame f-edt
       editing: readkey.
                apply last-key.
                if frame-field = "v-code" then apply "value-changed" to v-code in frame f-edt.
       end.

if v-code = "" then do:
  find sub-cod where sub-cod.sub = v-sub and sub-cod.d-cod = v-codfr and sub-cod.acc = s-cif exclusive-lock no-error.
  if avail sub-cod then delete sub-cod.
end.
else do:
  find sub-cod where sub-cod.sub = v-sub and sub-cod.d-cod = v-codfr and sub-cod.acc = s-cif exclusive-lock no-error.
  if not avail sub-cod then do:
    create sub-cod.
    assign sub-cod.sub = v-sub
           sub-cod.d-cod = v-codfr
           sub-cod.acc = s-cif
           sub-cod.rdt = g-today.
  end.
  sub-cod.ccode = v-code.

  release sub-cod.
end.

