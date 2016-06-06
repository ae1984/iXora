/* prildat.i
 * MODULE
        Отчет по распределению платежного оборота  
 * DESCRIPTION
        Отчет по распределению платежного оборота  
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        prildat.p
 * MENU
        8-12-9-12 
 * AUTHOR
        15.04.05 nataly
 * CHANGES
*/
   for each txb.jl no-lock where  txb.jl.jdt = v-dat1 and txb.jl.gl = {&gl} use-index jdt .
       create  temp2. 
       temp2.acc = txb.jl.acc. temp2.jh = txb.jl.jh.  temp2.crc = txb.jl.crc.
       if not rem[1] + rem[2] matches '*расч*' and  not rem[1] + rem[2] matches '*возмещ*' and not rem[1] + rem[2] matches '*взаимозачет*' 
            then  do: temp2.jdt = txb.jl.jdt. temp2.col1 = 1.  temp2.priz = 'без откр счета'. temp2.bank = v-branch. end.
            else  do: temp2.jdt = txb.jl.jdt. temp2.col1 = 1.  temp2.priz = 'платеж ордер'. temp2.bank = v-branch. end.
            
       find last txb.crchis where txb.crchis.crc = txb.jl.crc  and crchis.rdt <= jl.jdt   use-index crcrdt no-lock no-error.
       if avail txb.crchis then do:
             temp2.bal = (txb.jl.dam + txb.jl.cam) * txb.crchis.rate[1].  
       end.
   end. /*jl*/
