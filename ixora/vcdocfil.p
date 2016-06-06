/* vcdocfil.p
 * MODULE
        Валютный контроль
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
        BANK COMM TXB             
 * AUTHOR
      26.05.2008 galina     
 * CHANGES
      27.05.2008 galina - перекопеляция
*/

def input parameter p-codfr as char.


{vcdocfil.i 
 &head = "codfr"
 &codfr = "p-codfr"
}