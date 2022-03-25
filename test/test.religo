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

let assert_string_faliure = ((res, expected): (test_exec_result,
   string)): unit => {
  let expected = Test.compile_value(expected);
  switch (res) {
  | Fail(Rejected(actual, _)) =>
      assert(Test.michelson_equal(actual, expected))
  | Fail(Other) =>
      failwith("contract failed for an unkown reason")
  | Success(_) => failwith("bad price check")
  }
};

let test = 
  let init_storage = 

    Map.literal([(1n,
         {
           current_stock: 50n,
           max_price: 50000000mutez
         }),
       (2n, {current_stock: 20n, max_price: 75000000mutez })]);
  let (pedro_taco_shop_ta, _code, _size) = 
    Test.originate(buy_taco, init_storage, 0mutez);
  let pedro_taco_shop_ctr = 
    Test.to_contract(pedro_taco_shop_ta);
  let pedro_taco_shop = Tezos.address(pedro_taco_shop_ctr);
  let classico_kind = 1n;
  let unkown_kind = 3n;
  let eq_in_map = ((r, m, k): (taco_supply,
     taco_shop_storage, nat)): bool => 
    switch (Map.find_opt(k, m)) {
    | None => false
    | Some(v) =>
        v.current_stock == r.current_stock && v.max_price == r.
              max_price
    };
  let ok_case: test_exec_result = 

    Test.transfer_to_contract(pedro_taco_shop_ctr,
       classico_kind,
       1000000mutez);
  let _u = 
    switch (ok_case) {
    | Success(_) =>
        let storage = Test.get_storage(pedro_taco_shop_ta);

        assert(
          eq_in_map({
              current_stock: 49n,
              max_price: 50000000mutez
            },
             storage,
             1n) && 
             eq_in_map({
                 current_stock: 20n,
                 max_price: 75000000mutez
               },
                storage,
                2n))
    | Fail(x) => failwith("ok test case failed")
    };
  let nok_unknown_kind = 

    Test.transfer_to_contract(pedro_taco_shop_ctr,
       unkown_kind,
       1000000mutez);
  let _u = 

    assert_string_faliure(nok_unknown_kind,
       "Unknown kind of taco");
  let nok_wrong_price = 

    Test.transfer_to_contract(pedro_taco_shop_ctr,
       classico_kind,
       2000000mutez);
  let _u = 

    assert_string_faliure(nok_wrong_price,
       "Sorry, the taco you are trying to buy has a different price");
  ();
