/* xofc.f
 * MODULE
        Управление офицерами Прагмы
 * DESCRIPTION
        Фрейм для редактирования данныз
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9.1.5.8
 * AUTHOR
        31.12.1999 pragma
 * CHANGES
        23.08.2004 sasco   - добавил настройку пакетов доступа
*/


         ofc.ofc label 'ОФИЦЕР' skip 
         vpoint label 'ПУНКТ' help ' F2 - список пунктов' 
            validate(can-find (point where point.point = vpoint no-lock),
            ' Ошибочный код пункта - повторите ! ')
         vdep label 'ДЕПАРТАМЕНТ' help ' F2 - список департаментов' 
            validate(can-find (ppoint where ppoint.point = vpoint and ppoint.depart = vdep no-lock),
            ' Ошибочный код департамента - повторите ! ') skip
         vprofit label 'ПРОФИТ-ЦЕНТР' format 'x(3)' help ' F2 - список Профит-центров' 
            validate(can-find(codfr where codfr.codfr = 'sproftcn' and 
                codfr.code = vprofit and codfr.code matches '...' and codfr.code <> 'msc' no-lock),
            ' Ошибочный код Профит-центра - повторите ! ')
         v-tn label 'ТАБ.НОМЕР' format 'x(4)' help ' F2 - список сотрудников' 
            validate(v-tn = '' or can-find(ofc-tn where ofc-tn.tn = v-tn no-lock),
            ' Ошибочный табельный номер - проверьте по списку п.9.1.5.10 ! ') skip
         v-profitname label '' format 'x(45)' skip
         ofc.name label 'ИМЯ,ФАМИЛИЯ' format 'x(45)'
             validate(ofc.name <> '', ' Введите полное имя офицера ! ') skip
         ofc.addr[1] label 'АДРЕС' format 'x(45)'
         ofc.addr[2] label 'АДРЕС' format 'x(45)'
         ofc.expr[1] label 'ПАКЕТЫ ДОСТУПА' format 'x(45)' 
         ofc.tel label 'ТЕЛЕФОН' skip
         ofc.regdt label 'РЕГ.ДАТА' 
         ofc.indt label 'ПРИНЯТ.ДАТА' skip 
         ofc.tit label 'ТИТУЛ(КОНТРОЛ)' format 'x(45)' skip
         ofc.lang label 'ЯЗЫК МЕНЮ' format 'x(4)' validate(ofc.lang <> '', ' Выберите язык меню ! ')
         ofc.expr[5] label 'ПРАВА' format 'xxxxxx' skip
/*         ofc.edu label 'ОБРАЗОВАНИЕ' format 'x(45)' */
         ofc.bdt label      'ДАТА РОЖДЕНИЯ' 
         ofc.visadt label 'ПАРОЛЬ ИЗМЕНЕН'
         v-fdt label 'БЛОКИРОВАН С' 
         v-tdt label ' ПО'
             validate ((v-fdt = ? and v-tdt = ?) or v-tdt >= v-fdt, ' Дата конца периода не может быть меньше даты начала !')
         skip v-accd label 'ОГРАНИЧ.КОНТР.' help ' Ограничение контроля счетов менеджерами работающими в выходные' 
         v-uvol label 'УВОЛЕН' 



