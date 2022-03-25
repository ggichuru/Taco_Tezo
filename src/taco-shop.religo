type taco_supply = {current_stock: nat, max_price: tez };

type taco_shop_storage = map(nat, taco_supply);

type return = (list(operation), taco_shop_storage);

let init_storage: taco_shop_storage = 

  Map.literal([(1n,
       {
         current_stock: 50n,
         max_price: 50mutez
       }),
     (2n, {current_stock: 20n, max_price: 75mutez })]);

let buy_taco = ((taco_kind_index, taco_shop_storage): (nat,
   taco_shop_storage)): return => {
  let taco_kind: taco_supply = 
    switch (Map.find_opt(taco_kind_index, taco_shop_storage)) {
    | Some k => k
    | None =>
        (failwith("Unknown kind of taco") : taco_supply)
    };
  let current_purchase_price: tez = 
    taco_kind.max_price / taco_kind.current_stock;
  let x: unit = 
    if(Tezos.amount != current_purchase_price) {


      failwith("Sorry, the taco you are trying to buy has a different price")
    };
  let taco_shop_storage = 

    Map.update(taco_kind_index,
       (Some
         ({...taco_kind,
            current_stock: abs(taco_kind.current_stock - 1n)})),
       taco_shop_storage);
  (([] : list(operation)), taco_shop_storage)
};
