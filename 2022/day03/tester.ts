import { RuckSack, group_item_score, item_score } from "./solution"


{
  const A = new RuckSack("AAAAAAAAAAAAAAAAAAcAAAA");
  const B = new RuckSack("bbbbbbbbbbbbbbbbbbcbbbb");
  const C = new RuckSack("ccccccccccccccccccccccc");

  let res = group_item_score([A, B, C]);
  if (res != 3) {
    throw 'err'
  }
}
{
  const A = new RuckSack("asntehasnteuhasnthaunsoeth");
  const B = new RuckSack("asnoteuhasonethaoesnutahoeusn");
  const C = new RuckSack("asoneuthaouestnh");

  let res = group_item_score([A, B, C]);
  console.log(res)
}
{
  const A = new RuckSack("AAAAAAAAAAAAAAAAAAcAAAA");
  const B = new RuckSack("bbbbbbbbbbbbbbbbbbcbbbb");
  const C = new RuckSack("ccccccccccccccccccccccc");

  let res = group_item_score([A, B, C]);
  if (res != 3) {
    throw 'err'
  }
}

console.log("done")

