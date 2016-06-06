/* ibcomrmz.i
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
*/


    if remtrz.cracc = "019467476" or 
       (trim (remtrz.cracc) = "" and remtrz.racc = "019467476")
    then do: 

        define var i-phones as int.
        define var v-kcell_phones as char init "".
        define var kcell-ref as char format "x(10)" init "0".
        define var i_rid as integer.
	define var s_name as char format "x(50)".
	define var s_nameprev as char format "x(50)".
	define var v_rmz_detpay as char.

        if (remtrz.jh2 <> 0) and (remtrz.jh2 <> ?) then kcell-ref = remtrz.remtrz.
        else
        if (remtrz.jh1 <> 0) and (remtrz.jh1 <> ?) then kcell-ref = remtrz.remtrz.

        v_rmz_detpay = trim(remtrz.detpay[1]) +
                       trim(remtrz.detpay[2]) +
                       trim(remtrz.detpay[3]) +
                       trim(remtrz.detpay[4]).

        if length(v_rmz_detpay) = 7 then do:
                                        i-phones = int(v_rmz_detpay) no-error.
                                        if i-phones = 0 then v-kcell_phones = "0000000".
                                                       else v-kcell_phones = v_rmz_detpay.
                                    end.
                                    else v-kcell_phones = "0000000".

/*
        if remtrz.source = 'IBH' then
        i_rid = 1.
        else
        i_rid = 0.
*/
	i_rid = 1.

	s_nameprev = remtrz.ord.
        s_name = entry(1,s_nameprev,"/").

        if seltown = "TXB00" then do:                                                                  
           create mobtemp.                                                                                
           assign mobtemp.valdate = today                                                                    
                  mobtemp.cdate = g-today                                                                   
                  mobtemp.ctime = time                                                                    
                  mobtemp.sum = remtrz.amt
                  mobtemp.who = g-ofc                                                                     
                  mobtemp.state = 3                                                                       
                  mobtemp.phone = v-kcell_phones
                  mobtemp.ref = kcell-ref
                  mobtemp.joudoc = kcell-ref
                  mobtemp.rid = i_rid
                  mobtemp.npl = v_rmz_detpay
                  mobtemp.info = s_name
                  no-error.                                                                               
        end.                                                                                              
        else run ibcomtxa (today, g-ofc, kcell-ref, v-phones, remtrz.amt, v_rmz_detpay, i_rid, s_name).

    end.
