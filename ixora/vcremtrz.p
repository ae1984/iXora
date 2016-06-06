/*vcremtrz .p
 * MODULE
        Вал.кон.
 * DESCRIPTION
        Акцепт платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9.11
 * AUTHOR
        24.10.2008 galina
 * BASES
        BANK
 * CHANGES
       17/03/2009 galina - добавила платежи типа М (внутрибанковские платежи через интернет банкинг)
       19/03/2009 galina - добавила внутренние платежи
*/

{global.i}



def new shared var v-option as char.
def new shared var s-remtrz as char format "x(10)". 
define new shared variable s-newrec as logical.
def temp-table t-remtrz like remtrz.
def var v-remtrz as char.

define new shared variable s-docnum   like joudoc.docnum.
def temp-table t-joudoc like joudoc.
def var v-doctype as integer.
def var result as integer.
def var v_dres as integer.
def var v_cres as integer.

form
 v-doctype format '9' label "Тип платежа" help "1 - Внешние платежи; 2 - Внутренние платежи" validate(index('12', v-doctype) > 0,'Неверный тип платежа')
with centered side-label row 5 title "ТИП ПЛАТЕЖА" frame f-pay.
v-doctype = 1.
update v-doctype with frame f-pay.

if v-doctype = 1 then do:
  empty temp-table t-remtrz.
  for each remtrz where remtrz.jh2 = ? and remtrz.vcact = "" /* and remtrz.source <> "A"*/ and (remtrz.ptype = "4" or remtrz.ptype = "6" or remtrz.ptype = "N" or remtrz.ptype = "M" ) no-lock:
    if substr(remtrz.sqn,19) matches "ДПС*" then next.

    if remtrz.source = "IBH" and remtrz.jh1 <> ? then next.

    find first que where que.remtrz = remtrz.remtrz no-lock no-error.
    if avail que and que.pid = "ARC" then next.

    find first sub-cod where sub-cod.sub   = 'rmz' 
                           and sub-cod.acc   = remtrz.remtrz 
                           and sub-cod.d-cod = 'eknp' no-lock  no-error.
    if substr(sub-cod.rcode,1,1) = "2" or substr(sub-cod.rcode,4,1)= "2" then do:
       create t-remtrz.
       buffer-copy remtrz to t-remtrz.        
    end.
    if substr(sub-cod.rcode,1,1) = "1" and substr(sub-cod.rcode,4,1)= "1" then do:
       if remtrz.fcrc <> 1 then do:
             create t-remtrz.
             buffer-copy remtrz to t-remtrz.        
       end.
    end.
  end.  

  define query qt for t-remtrz.
  define browse bt query qt
          displ t-remtrz.remtrz  label "Платеж"
               t-remtrz.fcrc label "Вал.Д" 
               t-remtrz.amt label "СуммаД" 
               t-remtrz.tcrc label "Вал.К"
               t-remtrz.payment label "СуммаК"
               with 10 down no-label no-box.
             
  define frame ft bt with width 80 row 3 column 10 no-label title "ПЛАТЕЖИ".

  form
   v-remtrz label "N" format "x(10)" help "ALL - Все платежи"
  with centered side-label row 5 title "НОМЕР ПЛАТЕЖА" frame f-par.

  v-remtrz = "ALL".
  update v-remtrz with frame f-par.

  if v-remtrz <> "ALL" then do:
     find t-remtrz where t-remtrz.remtrz = v-remtrz no-lock no-error.
     s-remtrz = v-remtrz.
     v-option = "vcremout".
     if not avail t-remtrz then do:
        message "Платеж не найден!" view-as alert-box.
        return.
     end.
     run vcs-rotrz.
  end.

  on "return" of bt in frame ft do: 
      find current t-remtrz no-lock.
       s-remtrz = t-remtrz.remtrz.   
       v-option = "vcremout".
       run vcs-rotrz.
       find remtrz where remtrz.remtrz = s-remtrz no-lock.

       if remtrz.vcact <> "" then do:
          find t-remtrz where t-remtrz.remtrz = s-remtrz.
          delete t-remtrz.
       end.
  end.  
  if v-remtrz = "ALL" then do:
    open query qt for each t-remtrz where (v-remtrz = "ALL" or t-remtrz.remtrz = v-remtrz) no-lock.
    bt:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
    enable bt with frame ft.
    WAIT-FOR endkey of frame ft.
    hide frame ft.
  end.
end.
/**/
else do:
  empty temp-table t-joudoc.
  for each joudoc where joudoc.jh = ? no-lock:
    if joudoc.dracctype <> "2" or joudoc.cracctype <> "2" then next.  
     
    
    if joudoc.rescha[2] <> '' then next.
    run chk_valcon(joudoc.docnum, output v_dres, output v_cres, output result).
    
    if result > 0 then do:
       create t-joudoc.
       buffer-copy joudoc to t-joudoc.
    end.
    else next.
  end.  
  define query qt1 for t-joudoc.
  define browse bt1 query qt1
          displ t-joudoc.docnum  label "Платеж"
                t-joudoc.drcur label "Вал.Д" 
                t-joudoc.dramt label "СуммаД" 
                t-joudoc.crcur label "Вал.К"
                t-joudoc.cramt label "СуммаК"
                with 10 down no-label no-box.
             
  define frame ft1 bt1 with width 80 row 3 column 10 no-label title "ПЛАТЕЖИ".

  form
   s-docnum label "N" format "x(10)" help "ALL - Все платежи"
  with centered side-label row 5 title "НОМЕР ПЛАТЕЖА" frame f-par1.

  s-docnum = "ALL".
  update s-docnum with frame f-par1.

  if s-docnum <> "ALL" then do:
     find t-joudoc where t-joudoc.docnum = s-docnum no-lock no-error.
     if not avail t-joudoc then do:
        message "Платеж не найден!" view-as alert-box.
        return.
     end.
     else run vcjou.
  end.

  on "return" of bt1 in frame ft1 do: 
      find current t-joudoc no-lock.
       s-docnum = t-joudoc.docnum.   
       
       run vcjou.
       find joudoc where joudoc.docnum = s-docnum no-lock.

       if joudoc.rescha[2] <> "" then do:
          find t-joudoc where t-joudoc.docnum = s-docnum.
          delete t-joudoc.
       end.
  end.  
  if s-docnum = "ALL" then do:
    open query qt1 for each t-joudoc where (s-docnum = "ALL" or t-joudoc.docnum = s-docnum) no-lock.
    bt1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
    enable bt1 with frame ft1.
    WAIT-FOR endkey of frame ft1.
    hide frame ft1.
  end.
end.





