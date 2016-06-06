/* ver1.f
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Форма для отображения МБД
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
        24.09.05 ten
 * CHANGES
*/

/* ver1.f
  вызывается в viewer.p - просмотр сделки 
*/

form deal.deal      label "Сделка......." space(16)
     v-fungrp                            format "zz9" validate(can-find
                                    (fungrp where fungrp.fungrp =  fun.grp)," ")
                  label "Группа......." help " " skip
     fun.crc        label "Валюта......." space(24) 
     fun.basedy   label "Дней в году.." skip
     c-gl         label "Счет........." format "x(60)" skip
     bankl.bank   label "Контрагент..." format 'x(10)'  
     fun.cst                            format "x(54~)"  no-label             
     deal.prn     label "Сумма........" format "zz,zzz,zzz,zzz.99" skip 
     fun.rdt   label "Дата рег....." space(18)
     deal.maturedt   label "Дата заверш.."  validate(fun.duedt > fun.rdt," ") skip
     fun.duedt label "Дата пролонг." validate(fun.duedt > fun.rdt," ") skip
     fun.trm         label "Срок дней...." space(22)
     deal.inttype label "Тип %........" validate(deal.inttype = "A" or 
                                                 deal.inttype = "D"," ")  skip
     fun.intrate label "% ставка....." format "zz9.9999" space(18) 
     fun.interest  label "Сумма %......" format "z,zzz,zzz,zzz,zz9.99"  skip
     fun.rem      label "Примечания..." skip
     fun.dam[1]   label "Дебет суммы.." validate(fun.dam[1] <= fun.amt," Неверно: 
                               Дебет суммы больше суммы сделки")
                                        space(5)
     fun.cam[1]   label "Кредит суммы." validate(fun.cam[1] <= fun.amt,"Неверно: 
                               Кредит суммы больше суммы сделки ") skip
     fun.dam[2]   label "Дебет %......" space(5) 
     fun.cam[2]   label "Кредит %....." skip
     dkav         label "Дебет проср.." format "z,zzz,zzz,zzz,zz9.99" 
                                        validate(dkav <= fun.cam[1]," ")                                         space(6)
     ckav         label "Кредит проср." format "z,zzz,zzz,zzz,zz9.99"
                                        validate(ckav <= dkav," ") skip
     dblok        label "Дебет блок..." format "z,zzz,zzz,zzz,zz9.99" 
                                        validate(dblok <= ckav," ")
                                        space(6)
     cblok        label "Кредит блок.." format "z,zzz,zzz,zzz,zz9.99"
                                        validate(cblok <= dblok," ")   skip
     scn-s        label "100% обеспеч." format "z,zzz,zzz,zzz,zz9.99" space(6)
     scf-s        label "Факт.обеспеч." format "z,zzz,zzz,zzz,zz9.99" skip
     v-klmbd      label "Гр.классиф..."
                                        validate(can-find
                                        (codfr where codfr.codfr = "klmbd" and 
                                       codfr.code = string(v-klmbd,"999"))," ") 
                                        format "zz9"
     kl-n         no-label              format "x(24)"  skip
     ndn-s        label "Норма пров..." format "z,zzz,zzz,zzz,zz9.99" space(6)
     ndf-s        label "Факт.провиз.." format "z,zzz,zzz,zzz,zz9.99"
                                        validate(ndf-s <= ndn-s," ")
     with frame fun row 3 side-label centered  no-box width 80 .



