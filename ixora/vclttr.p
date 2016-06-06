/* pkdebts.p
 * MODULE
       Валютный контроль
 * DESCRIPTION
       Письма о лицензировнаии 
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15.8
 * AUTHOR
        13.05.2004 tsoy
 * CHANGES
         18.05.2004 tsoy изменил заголовок
         26.08.2009 galina - формируем другие письма
         27.08.2009 galina - перекопиляция
*/

def new shared var s-contract like vccontrs.contract.
def new shared var s-contrstat as char initial 'all'.
def new shared var s-cif like cif.cif.
def var v-select as integer.

def var v-contrnum as char.

def var v-cifname as char.
def frame f-client 
  s-cif label "КЛИЕНТ " format "x(6)" colon 10 help " Введите код клиента (F2 - поиск)"
    validate (can-find(first cif where cif.cif = s-cif no-lock), " Клиент с таким кодом не найден!")
  v-cifname no-label format "x(45)" colon 18
  v-contrnum label "КОНТРАКТ" format "x(50)" colon 10 help " Выберите контракт (F2 - поиск)"
    validate(v-contrnum <> "" and can-find(first vccontrs where vccontrs.ctnum + ' от ' + string(vccontrs.ctdate, "99/99/9999") begins trim(v-contrnum) and vccontrs.cif = s-cif no-lock), " Контракт не найден!") skip
with side-label width 100 row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".    

on help of v-contrnum in frame f-client do:
 run h-contract.
 if s-contract <> 0 then do:
    find vccontrs where vccontrs.contract = s-contract no-lock no-error.
    v-contrnum = vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999").
    displ v-contrnum with frame f-client.
 end.
end.

repeat:
  v-select = 0.

  run sel2 (" Письма ", " 1. Письма о предоставлении документов | 2. Письма о подтверждении закрытия ПС| 3. Платежи по контрактам| ВЫХОД ", output v-select).

  if v-select = 0 then return.
  if v-select <> 4 then do:
    s-cif = ''.
    v-cifname = ''.
    
    v-contrnum = ''.
    update s-cif with frame f-client. 
    
    find first cif where cif.cif = s-cif no-lock no-error.
    v-cifname = trim((cif.prefix) + " " + trim(cif.name)).
    displ v-cifname with frame f-client.
    v-contrnum = ''.
    update v-contrnum with frame f-client.
    if s-contract = 0 then find first vccontrs where vccontrs.ctnum = trim(v-contrnum) and vccontrs.cif = s-cif no-lock no-error.
    v-contrnum = vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999").
    displ v-contrnum with frame f-client.
  end.  
    
  case v-select:

    when 1 or when 2 or when 3 then run vcletter(v-select,s-cif,vccontrs.ctnum,v-cifname, '').
    when 4 then return.    
  end.
end.

