export interface HDMGoodsItem {
  id: string
  name: string
  desc: string
  price: string
  picture: ResourceStr
  orderNum: number
}

export interface CategoryItem {
  children?: CategoryItemChild[]
  goods?: HDMGoodsItem[]
  id: string
  name: string
  picture: ResourceStr
}

export interface CategoryItemChild {
  id: string
  name: string
  picture: ResourceStr
}

// 猜你喜欢的参数
export interface GuessParams {
  page: number
  pageSize: number
}

// 搜索和猜你喜欢的返回类型
export interface GoodsItems {
  counts: number;
  items: HDMGoodsItem[];
  page: number;
  pages: number;
  pageSize: number;
}

// 购物车单品的数据类型
export interface CartGoods {
  count: number;
  id: string;
  name: string;
  picture: string;
  price: number;
  selected: boolean;
  skuId: string;
  stock: number;
  attrsText: string;
}

@ObservedV2
export class CartGoodsModel implements CartGoods {
  @Trace
  count: number = 0
  id: string = ''
  name: string = ''
  picture: string = ''
  price: number = 0
  @Trace
  selected: boolean = false
  skuId: string = ''
  stock: number = 0
  attrsText: string = ''

  constructor(model: CartGoods) {
    this.count = model.count
    this.id = model.id
    this.name = model.name
    this.picture = model.picture
    this.price = model.price
    this.selected = model.selected
    this.skuId = model.skuId
    this.stock = model.stock
    this.attrsText = model.attrsText
  }
}