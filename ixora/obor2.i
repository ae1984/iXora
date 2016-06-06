   for each txb.jl no-lock where (txb.jl.acc = {&arp} and txb.jl.gl = {&gl}
       and txb.jl.jdt = v-dat1)
       use-index acc .
    create  temp2. 
     temp2.acc = txb.jl.acc. temp2.jh = txb.jl.jh.  temp2.crc = txb.jl.crc.
     temp2.jdt = txb.jl.jdt. temp2.col1 = 1.  temp2.priz = 'mgram'. temp2.bank = v-branch.

      find last txb.crchis where txb.crchis.crc = txb.jl.crc 
      and crchis.rdt <= jl.jdt   use-index crcrdt no-lock no-error.
   if txb.jl.dc = 'd' then  temp2.bal = txb.jl.dam * txb.crchis.rate[1].  
   else   temp2.bal = txb.jl.cam * txb.crchis.rate[1].
 end. /*jl*/
