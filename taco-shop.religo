type taco_supply = {current_stock: nat, max_price: tez };

type taco_shop_storage = map(nat, taco_supply);

type return = (list(operation), taco_shop_storage);

let main = ((parameter, taco_shop_storage): (int,
   taco_shop_storage)): return => {
  (([] : list(operation)), taco_shop_storage)
};

let init_storage: taco_shop_storage = 

  Map.literal([(1n,
       {
         current_stock: 50n,
         max_price: 50000000mutez
       }),
     (2n, {current_stock: 20n, max_price: 75000000mutez })]);
