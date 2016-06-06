/* ver.f
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
        23.09.05 ten 
 * CHANGES
      
*/
 

/* ver.f
  вызывается в viewer.p - просмотр сделки 
  от 23.08.05 */

form deal.deal     label "Номер РЕПО" 
     v-fungrp      label "          Группа......" format "zz9" skip
     vgl           label "Гл.Книга...." 
     gl.des format "x(55)" no-label skip
     v-bankl       label "МФО.."  format 'x(9)' validate(can-find(bankl where
                         bankl.bank = v-bankl)," ")
     bankl.name    format "x(55)" no-label skip                                
     deal.atvalueon[3] label "Контрагент.. "  format 'x(50)'  skip
     deal.rem[3]   label "Вид ЦБ......" format 'x(12)' 
     codfr.name[1] label "NIN  ..."  format 'x(13)'
     deal.ncrc[1]  label "Номинал ЦБ.." format "zz,zzz,zzz,zz9"  skip
     deal.ncrc[2]  label "Кол-во ЦБ..." format "zzz,zzz,zz9" space(23)  
     deal.intrate  label "% ставка...." format "zz9.9999"   skip(1)

     v-add         label "Курс"         format 'zzz,zzz,zz9' skip
     deal.regdt    label "Дата сделки." 
     p-open        label "Цена откр. " format "zzzzzzz9.9999"  
     v-open        label "Объем откр." format "zzzzzzzzzzzz9.99" skip 

     deal.maturedt label "Дата закрыт." 
     p-close       label "Цена закр. " format "zzzzzzz9.9999"  
     v-close       label "Объем закр." format "zzzzzzzzzzzz9.99" skip
     deal.trm      label "К-во дней..." space(5) skip
     v-crc         label "Валюта......" format "z9" space(3)
     v-code        no-label skip

     deal.yield    label "Доход/Расход" format "z,zzz,zzz,zz9.99" skip(1)

     deal.arrange  label "Орг........." skip

     with frame deal2 row 3 side-label centered  no-box width 80.
