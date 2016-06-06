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
        11/06/2010 madiyar - расширил формат полей deal.atvalueon[1] и deal.atmaton[1] до 20 символов
*/

/* deal.f
  вызывается в deal.p - оформление сделки
  изменения от 13.10.2000 */

form deal.deal     label "Номер сделки"
     v-fungrp      label "          Группа......" format "zz9" skip
     vgl           label "Гл.Книга...."
     gl.des format "x(55)" no-label skip
     v-bankl       label "Контрагент.." validate(can-find(bankl where
                         bankl.bank = v-bankl)," ")
     bankl.name    format "x(55)" no-label skip
     deal.prn      label "Сумма......." format "z,zzz,zzz,zzz,zz9.99"
     v-crc         label "Валюта......" format "z9" space(3)
     v-code        no-label
     deal.yield    label "Прибыль....."
     deal.intamt   label "Сумма проц.." format "z,zzz,zzz,zzz,zz9.99"
     deal.totamt   label "Общая сумма." format "z,zzz,zzz,zzz,zz9.99"
     deal.regdt    label "Дата сделки." space(13)
     deal.valdt    label "Дата валютир"
          validate(deal.valdt >= g-today and deal.valdt >= deal.regdt," ")
     deal.maturedt label "Дата закрыт."
          validate(deal.maturedt >= deal.valdt," ")
     deal.trm      label "К-во дней..." space(17)      deal.info[3]  label "N аккредитив" format "x(15)" skip
     deal.intrate  label "% ставка...." format "zz9.9999" space(13)
     deal.inttype  label "Вид........."
                   validate(deal.inttype = "A" or deal.inttype = "D"," ")
     space(8)
     days          label "Дней........" skip
     deal.broke    label "Партнер....." format "x(5)" space(16)
     deal.info[1]  label "Тикет......." format "x(25)" skip
     deal.rem[3]   label "Код ЦБ......" format 'x(10)' space(11)
     codfr.name[1] label "Наим-ие ЦБ.." skip
     deal.ncrc[1]  label "Номинал ЦБ.." format "zz,zzz,zzz,zz9" space(7)
     deal.ncrc[2]  label "Кол-во ЦБ..." format "zzz,zzz,zz9" space(2)
     "Дата валютир   Банк : " deal.atvalueon[1] no-label format "x(20)"
                              deal.atvalueon[2] no-label skip
     "               FRB# : " deal.valfrb no-label skip
     "               Счет#: " deal.atvalueon[3] no-label skip
     "Дата закрытия  Банк : " deal.atmaton[1] no-label format "x(20)"
                              deal.atmaton[2] no-label skip
     "               FRB# : " deal.matfrb no-label skip
     "Через     корр-счет#: " deal.atmaton[3] no-label skip
     "Прим даты валютир.  : " deal.rem[1] no-label skip
     "Прим даты закрытия  : " deal.rem[2] format "x(20)" no-label skip
     with frame deal row 3 side-label centered  no-box width 80.

form cmd with frame slct row 22 no-box no-label overlay centered.

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
