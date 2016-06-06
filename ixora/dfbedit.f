/* dfbedit.f
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
        15.04.2009 galina  - не выводим поле dfb.grp
                             выводим 20-тизначный счет
        16.04.2009 galina - явно указала ширину фрейма dfb 
        17.04.2009 galina -  уменьшила ширину фрейма dfb    
                             добавила проверку на введенный код валюты и счет ГК               
*/

/* dfbedit.f
*/

  form    "NOSTRO#     : " v-dfb  space(12) "ВАЛЮТА      : " dfb.crc validate(can-find(crc where crc.crc = dfb.crc),'Неверный код валюты') skip
          "СчетГлКн.   : " dfb.gl validate(can-find(gl where gl.gl = dfb.gl and gl.sub = 'dfb'),'Неверный счет ГК')  space(16) skip
          "НАИМЕНОВАНИЕ: " dfb.name skip
          "АДРЕС       : " dfb.addr[1] skip
          "            : " dfb.addr[2] skip
          "            : " dfb.addr[3] skip
          "ТЕЛЕФОН     : " dfb.tel space(7)
          "  ФАКС        : " dfb.fax skip
          "ПРОЦ.СТАВКА : " dfb.intrate at 27 space(2)
          "КРЕДИТН.ЛИНИЯ : " dfb.crline at 55 skip
          "ВХ.ОСТ.ГОД  : " vyst space(1)
          "ДЕБЕТ ЗА ГОД: " vydr skip
          "КРЕДИТ ЗА ГОД : " at 36 vycr skip
          "ВХ.ОСТ.МЕСЯЦ: " vmst space(1)
          "ДЕБЕТ ЗА МЕС: " vmdr skip
          "КРЕДИТ  МЕС : " vmcr 
          "СТАТУС      : "  v-subcode " " v-subname format "x(15)" skip
          "ВХ.ОСТ.ВЧЕРА: " vtst space(1)
          "ДЕБЕТ ВЧЕРА : " vtdr skip
          "КРЕДИТ ВЧЕРА: " vtcr skip
          "ТЕКУЩ.ОСТАТ.: " vbal skip
          "ГОД АКК.СУМ.: " vyas
          "МЕС АКК.СУМ.: " vmas skip
          "ГОД ПОЛ.ПРОЦ: " vyir
          "ГОД ВЫП.ПРОЦ: " vyip skip
          "МЕС.ПОЛ.ПРОЦ: " vmir
          "МЕС.ВЫП.ПРОЦ: " vmip skip
          "ТЕЛЕКС      : " dfb.tlx space(12)
          "ССЫЛОЧНЫЙ N : " dfb.ref 
           with row 3 col 2 width 90 no-label no-box
               frame dfb.

form
    dfb.bank    label "КОР.БАНК  "
      validate(can-find(bankl where bankl.bank eq dfb.bank),"")
    dfb.geo     label "ГЕО#"   
      validate(can-find(geo where geo.geo eq geo) , "")
    dfb.duedt   label "НАЧ.ДАТА " format "99/99/99" 
    dfb.zalog   label "ЗАЛОЖЕН  ?"
    dfb.lonsec  label "ОБЕСПЕЧ" 
      validate(can-find(lonsec where lonsec.lonsec eq lonsec) 
      or dfb.lonsec eq 0, "")
    dfb.risk    label "РИСК "  
      validate(can-find(risk where risk.risk eq risk) 
      or dfb.risk eq 0,"")
    dfb.penny   label "ШТРАФ%" validate(penny <= 100, "")
    with frame dfb1 row 10 2 col centered overlay.

def var v-cod as char.
on help of v-subcode in frame dfb do:
   
   run h-codfr ("clsa", output v-cod).
   v-subcode = v-cod.
   find codfr where codfr.codfr = "clsa" and codfr.code = v-subcode no-lock no-error.
   if avail codfr then v-subname = codfr.name[1].
   displ v-subcode v-subname with frame dfb.
end.
