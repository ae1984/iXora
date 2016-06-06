/* depmofi.p
 * MODULE
        График перемещения сотрудников между подразделениями банка.
 * DESCRIPTION
        Перемещает офицеров меж. под-ями автоматически при закрытии дня и через пункт меню 12-2-13.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        (12-2-13 : Перемещение сотрудников между подразделениями)
 * AUTHOR
        01.08.06 - Isakov A. - файл создан
 * CHANGES
*/

{mainhead.i} 
{sysc.i}

def new shared var s-target as date.

def var bd   as date initial today no-undo.
def var ed   as date no-undo.
def var upd-it as log init true no-undo.
def var MainQuestion as log init true no-undo.

def var ofc like ofc.ofc.
def var ofcname like ofc.name.

def var labelout as int.
def var labelin  as int.

def var vdepout like ppoint.depart.
def var vprofitout like codfr.code.
def var v-profitnameout as char.

def var vdepin like ppoint.depart.
def var vprofitin like codfr.code.
def var v-profitnamein as char.

def var vpoint like point.point. 

form 
  ofc             label 'ОФИЦЕР' validate(can-find(ofc where ofc.ofc = ofc), 'Нет такого офицера!') skip 
  ofcname         label 'Ф.И.О.' format 'x(45)' skip
  /* ----------------------------------------------------------------------------------------------------------- */
  labelout        label "ИЗ ПОДРАЗДЕЛ-Я"
  vdepout         label 'ДЕПАРТАМЕНТ' help ' F2 - список департаментов'  
                        validate( can-find(ppoint where ppoint.point = vpoint and ppoint.depart = vdepout no-lock),
                        ' Ошибочный код департамента - повторите ! ') skip
  vprofitout      label 'ПРОФИТ-ЦЕНТР' format 'x(3)' help ' F2 - список Профит-центров' 
                        validate(can-find(codfr where codfr.codfr = 'sproftcn' and 
                        codfr.code = vprofitout and codfr.code matches '...' and codfr.code <> 'msc' no-lock),
                        ' Ошибочный код Профит-центра - повторите ! ')
  v-profitnameout label '' format 'x(45)' skip
  /* ----------------------------------------------------------------------------------------------------------- */
  labelin         label "В  ПОДРАЗДЕЛ-Е"
  vdepin          label 'ДЕПАРТАМЕНТ' help ' F2 - список департаментов'  
                         validate( can-find(ppoint where ppoint.point = vpoint and ppoint.depart = vdepin no-lock),
                         ' Ошибочный код департамента - повторите ! ') skip
  vprofitin       label 'ПРОФИТ-ЦЕНТР' format 'x(3)' help ' F2 - список Профит-центров' 
                         validate(can-find(codfr where codfr.codfr = 'sproftcn' and 
                         codfr.code = vprofitin and codfr.code matches '...' and codfr.code <> 'msc' no-lock),
                         ' Ошибочный код Профит-центра - повторите ! ')
  v-profitnamein  label '' format 'x(45)' skip
  /* ----------------------------------------------------------------------------------------------------------- */
  bd              label "ДАТА    НАЧАЛА" validate( bd >= g-today, 'Дата начала должна быть не раньше, чем сегодня(' + string(g-today) + ')!')
  ed              label "ДАТА ОКОНЧАНИЯ" 

with frame fr-1 1 column centered title "Введите данные".

on help of vprofitout in frame fr-1 do: 
  run uni_help1('sproftcn', '...'). 
end.

on help of vprofitin in frame fr-1 do: 
  run uni_help1('sproftcn', '...'). 
end.

on help of vdepout in frame fr-1 do: 
  { itemlist.i
    &where   = "ppoint.point = vpoint and ppoint.depart > 0"
    &file    = "ppoint"
    &frame   = "row 5 centered scroll 1 12 down overlay "
    &flddisp = "ppoint.depart ppoint.name "
    &chkey   = "depart" 
    &chtype  = "integer"
    &index   = "pdep"   
    &funadd  = "if frame-value = "" "" then do:
                { imesg.i 9205 }.
                pause 1.
                next.
                end."
    &set = "a" }
  
  vdepout = ppoint.depart.
  display vdepout with frame fr-1.
end.

on help of vdepin in frame fr-1 do: 
  { itemlist.i
    &where   = "ppoint.point = vpoint and ppoint.depart > 0"
    &file    = "ppoint"
    &frame   = "row 5 centered scroll 1 12 down overlay "
    &flddisp = "ppoint.depart ppoint.name "
    &chkey   = "depart" 
    &chtype  = "integer"
    &index   = "pdep"   
    &funadd  = "if frame-value = "" "" then do:
                { imesg.i 9205 }.
                pause 1.
                next.
                end."
    &set = "b" }
  
  vdepin = ppoint.depart.
  display vdepin with frame fr-1.
end.

vpoint = 1. /* 1 - это "Центральный офис" */ 

procedure defprofitname.
  find codfr where codfr.codfr = "sproftcn" and codfr.code = vprofitout no-lock no-error.
  if avail codfr then 
    v-profitnameout = codfr.name[1].
  else 
    v-profitnameout = "".
end procedure.

repeat:

  /* ввод даннах через фрейм : начало */
  if MainQuestion then /* фрейм не очищается только если ответили - Отмена в вопросе - "Сохранить введёные данные ?" */
    do:
      clear frame fr-1.
      ofc        = ''. 
      vdepout    = 0.   
      vdepin     = 0. 
      vprofitout = ''. 
      vprofitin  = ''. 
    end.     

  update ofc with frame fr-1.

  find ofc where ofc.ofc = ofc no-lock no-error.
  vdepout    = ofc.regno mod 1000.
  vprofitout = ofc.titcd. 
  ofcname    = ofc.name. 
  run defprofitname. 
  display ofcname vdepout vprofitout v-profitnameout with frame fr-1.
              
  /* ИЗ ПОДРАЗДЕЛ-Я ------------------------------------------------------------------ */
/*
  update vdepout with frame fr-1.
  
  if vdepout > 1 then 
    vprofitout = get-sysc-cha ("PCRKO") + string(vdepout, '99').
  else 
    update vprofitout with frame fr-1.

  find codfr where codfr.codfr = "sproftcn" and codfr.code = vprofitout no-lock no-error.
  if avail codfr then v-profitnameout = codfr.name[1].
                 else v-profitnameout = "".

  display vprofitout v-profitnameout with frame fr-1.
*/


  /* В  ПОДРАЗДЕЛ-Е ------------------------------------------------------------------ */
  repeat:
    update vdepin with frame fr-1.
    
    if vdepin > 1 then 
      vprofitin = get-sysc-cha ("PCRKO") + string(vdepin, '99').
    else 
      update vprofitin with frame fr-1.
  
    find codfr where codfr.codfr = "sproftcn" and codfr.code = vprofitin no-lock no-error.
    if avail codfr then v-profitnamein = codfr.name[1].
                   else v-profitnamein = "".
  
    display vprofitin v-profitnamein with frame fr-1.
    
    if vprofitin = vprofitout then 
      do:
        message "Ошибка в переводе!" skip
                "Нет смысла, делать перевод" skip 
                "в одно и тоже подразделение."   
        view-as alert-box.

        vdepin         = 0. 
        vprofitin      = ''. 
        v-profitnamein = ''.           
        displ vdepin vprofitin v-profitnamein  with frame fr-1.
      end.  
    else  
      leave.
   
  end.   
  /* --------------------------------------------------------------------------------- */
  if vdepin = 0 then 
    do: 
      displ "Нельзя перескакивать на дату(с помощью F4)," skip
            "если департамент не выбран!" with centered title "ПРЕДУПРЕЖДЕНИЕ" 1 down.
      return.
    end.  
  else 
    update bd 
           with frame fr-1.

  repeat:
    update ed 
           with frame fr-1.
    if ed = ? then 
      do:
        message "Сделать перевод в одностороннем порядке" skip 
                "(обратного перевода не будет)," skip 
                "без даты окончания."
                view-as alert-box question buttons yes-no UPDATE upd-it.
        if upd-it then 
          leave.
      end.  
    else  
      if ed < g-today then 
        message 'Дата окончания должна быть не раньше, чем сегодня(' + string(g-today) + ')!'.  
      else
        leave.  
  end.   

  /* ввод даннах через фрейм : конец */

  /* если при перемещение даты bd и ed равны, 
     то на след. день сотрудник будет обратно в своём подразделени */
  if ed = bd then 
    ed = ed + 1.  

  message "Сохранить введёные данные ?" 
  view-as alert-box question buttons yes-no-cancel UPDATE upd-it.

  if upd-it = yes then /* сохроняем */
    do:            
    
      do transaction:
        create tempsec.
        assign tempsec.ofc       = ofc
        
               tempsec.profitout = vprofitout
               tempsec.profitin  = vprofitin
               tempsec.depout    = vdepout
               tempsec.depin     = vdepin
        
               tempsec.bdat      = bd
               tempsec.edat      = ed
    
               tempsec.who       = g-ofc
               tempsec.whn       = today
               
               tempsec.type      = 7. /* новый тип прав : 7 - перемещение между подразделениями */
      end.
    
      if bd = g-today then 
        do:
          s-target = g-today.   
          run set_permissions(1). /* произвести перемещение сразу, если дата начала равна g-today */
        end.  
    
      message "Запись о перемещении офицера : " tempsec.ofc skip 
              ofcname skip
              "внесена в график." skip 
              "Продолжить ввод следующего офицера?"     
      view-as alert-box question buttons yes-no UPDATE upd-it.
              
      if upd-it then 
        ed = ?. 
      else 
        leave.
    
    end. /* end для do: после upd-it = yes */
  
  else
  
    do: 
      if upd-it = no then /* очищаем фрейм */
        MainQuestion = true. 
      else /* если cancel - то НЕ очищаем фрейм */
        MainQuestion = false. 
    end.

end.
