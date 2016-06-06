/* koval-vsd.i
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Коваль-всд.ишка для  отправки уведомлений о валютном контроле
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        23/05/06 sasco изменил отправителя в теле письма - вместо m_pid пишется PS <proc_ m_pid> @ texakabank.kz
        13/12/2011 Luiza - закоментировала весь текст
*/

/*** KOVAL Begin Отправка подтверждения Департаменту Платежных Систем ***/

/* if (get-dep (g-ofc, g-today) <> 1 and (m_pid = "G" or m_pid = "3A") and remtrz.tcrc <> 1) or
    (brnch and m_pid = "3A" and remtrz.tcrc <> 1)

if  ( (get-dep(g-ofc, g-today) <> 1 or ourcode <> 0 ) and (m_pid = "G" or m_pid = "3A") and remtrz.tcrc <> 1 )
then
run mail( "ps@elexnet.kz", "PS <proc_" + m_pid + "@elexnet.kz>", 'Exchange controls of branches ' + remtrz.remtrz,
'Внимание! ' + chr(10) + 'Отправлен ' + remtrz.remtrz + ' от TXB' + string(ourcode,"99") + chr(10) + 'Дата Валютирования 1 = ' +
string(remtrz.valdt1) + '  Валюта = ' + string(remtrz.fcrc) + chr(10) +
'  Сумма = ' + string(remtrz.amt,"->>>,>>>,>>>,>>9.99") + chr(10) + chr(10) + 'Отправлен и подтвержден валютный контроль ' + g-ofc +
' (' + get-fio(g-ofc) + ')', '1', '', '').*/

/*** KOVAL Begin Отправка подтверждения Департаменту Платежных Систем  ***/
