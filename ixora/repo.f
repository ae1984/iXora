/* deal.f
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
        31/12/99 pragma
 * CHANGES
        17.05.2004 расширил поле Вид ЦБ на 2 знака 
        23.09.05 тен добавил переменную v-add.
*/
 

/* deal.f
  вызывается в deal.p - оформление сделки 
  изменения от 13.10.2000 */

form deal.deal     label "Номер РЕПО" 
     v-fungrp      label "          Группа......" format "zz9" skip
     vgl           label "Гл.Книга...." 
     gl.des format "x(55)" no-label skip
     v-bankl       label "МФО........."  format 'x(9)' validate(can-find(bankl where
                         bankl.bank = v-bankl)," ")
     bankl.name    format "x(55)" no-label skip                                
     deal.atvalueon[3] label "Контрагент.."  format 'x(50)'  skip
     deal.rem[3]   label "Вид ЦБ......" format 'x(12)' skip
     codfr.name[1] label "NIN........."  format 'x(16)'
     deal.ncrc[1]  label "  Номинал ЦБ.." format "zz,zzz,zzz,zz9"  skip
     deal.ncrc[2]  label "Кол-во ЦБ..." format "zzz,zzz,zz9" space(23)  skip
     deal.intrate  label "% ставка...." format "zz9.9999"   skip(1)

     v-add         label "Курс........"         format 'zzz,zzz,zz9' skip
     deal.regdt    label "Дата сделки."  skip
/*     deal.prn      label " Цена откр. " format "zzz9.9999"  */
     p-open        label "Цена откр.. " format "zzzzzzzzzz9.9999"  
     v-open        label "  Объем откр. " format "zzzzzzzzzzzz9.99" skip 

     deal.maturedt label "Дата закрыт." skip
     p-close       label "Цена закр.. " format "zzzzzzzzzz9.9999"  
     v-close       label "  Объем закр. " format "zzzzzzzzzzzz9.99" skip
     d-close       label "Дата пролон" skip(1)
        /*  validate(deal.maturedt >= deal.valdt," ")  */

     deal.trm      label "К-во дней..." space(5) skip
     v-crc         label "Валюта......" format "z9" space(3)
     v-code        no-label skip

     deal.yield    label "Доход/Расход" format "z,zzz,zzz,zz9.99" skip(1)

     deal.arrange  label "Орг........." skip

     with frame deal2 row 3 side-label centered  no-box width 80.

form deallong.deal     label "Номер РЕПО" 
     v-fungrp      label "          Группа......" format "zz9" skip
     vgl           label "Гл.Книга...." 
     gl.des format "x(55)" no-label skip(2)

     deallong.rem[3]   label "Вид ЦБ......" format 'x(10)' space(1) 
     codfr.name[1] label "NIN  ..."  format 'x(13)'
     deallong.ncrc[1]  label "Номинал ЦБ.." format "zz,zzz,zzz,zz9"  skip
     deallong.ncrc[2]  label "Кол-во ЦБ..." format "zzz,zzz,zz9" space(23)  
     deallong.intrate  label "% ставка...." format "zz9.9999"   skip(1)

     deallong.regdt    label "Дата сделки." 
/*     deal.prn      label " Цена откр. " format "zzz9.9999"  */
     p-open        label "Цена откр. " format "zzzzzzz9.9999"  
     v-open        label "Объем откр." format "zzzzzzzzzzzz9.99" skip 

     deallong.maturedt label "Дата закрыт." 
     p-close       label "Цена закр. " format "zzzzzzz9.9999"  
     v-close       label "Объем закр." format "zzzzzzzzzzzz9.99" skip(1)
        /*  validate(deal.maturedt >= deal.valdt," ")  */

     deallong.trm      label "К-во дней..." space(5) skip
     v-crc         label "Валюта......" format "z9" space(3)
     v-code        no-label skip

     deallong.yield    label "Доход/Расход" format "z,zzz,zzz,zz9.99" skip(1)

   /*  deallong.arrange  label "Орг........." skip*/

     with frame deallong row 3 side-label centered  no-box width 80.

form cmd with frame slct row 27 no-box no-label overlay centered.

form 
     deal.geo format "x(3)" label "ГЕО........"
        validate(can-find(geo where geo.geo eq geo)
        or deal.geo eq "", "")
     deal.zalog   label "Залог ?...."
     deal.lonsec  label "Обеспеч...." 
        validate(can-find(lonsec where lonsec.lonsec eq lonsec) 
        or deal.lonsec eq 0, "")
     deal.risk    label "Риск......."
        validate(can-find(risk where risk.risk eq risk) 
        or deal.risk eq 0, "")
     deal.penny   label "% пени....." validate(penny <= 100, "") 
     sub-cod.ccode  label "Сектор экономики"

     with frame funacr row 10 centered 1 col width 60 overlay 
     title "ТИП".
