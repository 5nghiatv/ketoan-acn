<template>
    <!-- eslint-disable -->
    <div class="productForm">
        <form id="productCU" @submit="actionProduct" v-if="!loading">
                <p v-if="errors.length">
                  <b>Please correct the following error(s):</b>
                  <ul>
                    <li v-for="error in errors" :key="error">{{ error }}</li>
                  </ul>
                  <!-- eslint-disable-next-line -->
                </p>

              <div class="form-group">
                <label for="productName">Product Name</label>
                <input type="text" class="form-control" id="productName" v-model="product.productName" name="productName" aria-describedby="emailHelp" placeholder="Enter Product Name">
                <!-- <small id="emailHelp" class="form-text text-muted">We'll never share your email with anyone else.</small> -->
              </div>
              <div class="row">
                <div class="col">

                  <div class="form-group">
                    <label for="productCategory">Product Category</label>
                    <select class="form-control"  v-if="product.productCategory !== 'Create New'" id="productCategory" name="productCategory" v-model="product.productCategory">
                        <option 
                          v-for="(category, index) in categories" :key="index" 
                          v-bind:value="category.productCategory" 
                          >{{category.productCategory}}
                        </option>
                    </select>
                    <input type="text" class="form-control" id="productCategoryDummy"  v-if="product.productCategory === 'Create New'" placeholder="Product Categroy" name="productCategoryDummy" v-model="product.productCategoryDummy">
                  </div>
                </div>

                <div class="col">
                  <div class="form-group">
                    <label for="productSeller">Product Seller</label>
                    <select class="form-control"  v-if="product.productSeller !== 'Create New'" id="productSeller" name="productSeller" v-model="product.productSeller">
                        <option 
                          v-for="(seller, index) in sellers" :key="index" 
                          v-bind:value="seller.productSeller" 
                          >{{seller.productSeller}}
                        </option>
                    </select>
                    <input type="text" class="form-control" id="productSellerDummy"  v-if="product.productSeller === 'Create New'" placeholder="Product Seller" name="productSellerDummy" v-model="product.productSellerDummy">
                  </div>
                </div>

              </div>

              <div class="row">
                <div class="col">
                  <div class="form-group">
                    <label for="isBestProduct">Best Product</label>
                    <input type="checkbox" class="form-control" id="isBestProduct" name="isBestProduct" v-model="product.isBestProduct" placeholder="Password">
                  </div>
                </div>
                <div class="col">
                    <div class="form-group">
                      <label for="isTopProduct">Top Product</label>
                      <input type="checkbox" class="form-control" id="isTopProduct" name="isTopProduct" placeholder="Password" v-model="product.isTopProduct">
                    </div>
                </div>
                <div class="col">
                  <div class="form-group">
                    <label for="productRating">Product Rating</label>
                    <input type="text" class="form-control" id="productRating" v-model="product.productRating" placeholder="Product Rating">
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col">
                  <div class="form-group">
                    <label for="productImage">Product Image</label>
                    <input type="text" class="form-control" id="productImage" v-model="product.productImage" placeholder="Product Image URL">
                  </div>
                </div>
                <div class="col">
                  <div class="form-group">
                    <label for="productImage">Product Price</label>
                    <input type="text" class="form-control" id="productPrice" v-model="product.productPrice" placeholder="Product Price">
                  </div>
                </div>
              </div>
              <div class="form-group">
                <label for="productImage">Product Description</label>
                <input type="text" class="form-control" id="productDescription" v-model="product.productDescription" placeholder="Product Description">
              </div>
              <br>
              <div class="d-flex justify-content-center">
                  <button type="submit" class="btn btn-outline-info">Save changes</button>&nbsp;&nbsp;
              </div>

        </form>
        <div class="d-flex justify-content-center">
          <div class="lds-dual-ring" v-if="loading"></div>
        </div>
    </div>
</template>
<script>
import axios from "axios";
import _ from "lodash";
export default {
  name: "productForm",
  props: ["product"],
  data() {
    return {
      errors: [],
      productCategoryDummy: "",
      productSellerDummy: "",
      categories: [],
      sellers: [],
      loading: false,
    };
  },
  methods: {
    actionProduct(event) {
      event.preventDefault();
      this.$emit("submit-form", this.product);
    },
  },
  created() {
    this.loading = true;
    axios
      .get(`${process.env.VUE_APP_BASE_URL}/products`)
      .then((response) => {
        // getting all products and getting the uniq value for
        // productCategory and returning the productCategory property only
        this.categories = _.uniqBy(
          _.map(response.data, function (object) {
            return _.pick(object, ["productCategory"]);
          }),
          "productCategory"
        );
        this.categories.push({ productCategory: "Create New" });

        // getting all products and getting the uniq value for
        // productSeller and returning the productSeller property only
        this.sellers = _.uniqBy(
          _.map(response.data, function (object) {
            return _.pick(object, ["productSeller"]);
          }),
          "productSeller"
        );

        this.sellers.push({ productSeller: "Create New" });

        this.loading = false;
      })
      .catch((error) => {
        console.log(error);
        this.$toastr.error("","Error while fetching products");
      });
  },
};
</script>
<style lang="css">
.productForm > div {
  text-align: start;
}
.productForm #productCU div {
  text-align: start;
}

.productForm #productCU button {
  text-align: center;
}

.lds-dual-ring {
  display: inline-block;
  width: 64px;
  height: 64px;
}
.lds-dual-ring:after {
  content: " ";
  display: block;
  width: 46px;
  height: 46px;
  margin: 1px;
  border-radius: 50%;
  border: 5px solid #fff;
  border-color: #41b883 transparent #41b883 transparent;
  animation: lds-dual-ring 1.2s linear infinite;
}
@keyframes lds-dual-ring {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}
</style>