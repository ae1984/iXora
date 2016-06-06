/* ispogntcheck.p
 * MODULE
        первая проводка для внешних платежей
 * DESCRIPTION
         
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * BASES
        BANK COMM TXB 
 * AUTHOR
        05.11.08  marinav
 * CHANGES
*/


     def input param v-racc as char.
     def shared var v-fl as logi init false.
        find txb.aaa where txb.aaa.aaa =  v-racc.
        if avail txb.aaa and txb.aaa.lgr = '236' then v-fl = true.
                                                 else v-fl = false.

     return. 
