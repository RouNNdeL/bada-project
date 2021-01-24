document.addEventListener("DOMContentLoaded", () => {
    function bindClickToPriceRange(btn) {
        btn.addEventListener("click", () => {
            btn.closest("li.priceRange").remove()
        });
    }

    document.querySelectorAll(".updateOrderForm").forEach(form => {
        form.querySelector("select").addEventListener("change", it => {
            const data = {
                status: it.target.value
            };

            fetch(form.action, {
                method: form.method,
                body: JSON.stringify(data),
                headers: {
                    'Accept': 'application/json, text/plain, */*',
                    'Content-Type': 'application/json'
                },
            }).then(() => {
                Snackbar.show({
                    text: "Saved successfully!"
                });
            }).catch(e => {
                Snackbar.show({
                    text: `Error: ${e}`
                });
            });
        });
    });

    const addPriceBtn = document.getElementById("addPriceRangeBtn");
    if (addPriceBtn !== null) {
        addPriceBtn.addEventListener("click", () => {
            const previousList = document.querySelectorAll("#priceRangeList > .priceRange")
            const previous = previousList[previousList.length - 1] || null
            const quantity = previous == null ? 1 :
                parseInt(previous.querySelector("input.priceRangeQuantity").value) + 10;
            const price = previous == null ? 1 :
                parseFloat(previous.querySelector("input.priceRangePrice").value);

            const template = document.getElementById("priceRangeTemplate");
            const clone = template.cloneNode(true);

            clone.removeAttribute("id");

            let quantityInput = clone.querySelector("input.priceRangeQuantity");
            let priceInput = clone.querySelector("input.priceRangePrice");

            quantityInput.value = quantity;
            priceInput.value = price;

            document.getElementById("priceRangeList").appendChild(clone);
            bindClickToPriceRange(clone.querySelector("button.removePriceRangeBtn"))
        });
    }

    const saveItem = document.getElementById("saveItem");
    if (saveItem !== null) {
        saveItem.addEventListener("click", () => {
            const rangeList = document.querySelectorAll("#priceRangeList > .priceRange")
            const data = {
                priceRanges: [],
                stock: []
            }

            rangeList.forEach(el => {
                const minQuantityInput = el.querySelector("input.priceRangeQuantity");
                const priceInput = el.querySelector("input.priceRangePrice");
                if (minQuantityInput == null || priceInput == null) {
                    return;
                }

                const minQuantity = parseInt(minQuantityInput.value);
                const price = parseFloat(priceInput.value);

                if (isNaN(minQuantity) || isNaN(price)) {
                    return;
                }

                data.priceRanges.push({minQuantity, price});
            });

            document.querySelectorAll("input.itemStock").forEach(el => {
                const quantity = parseInt(el.value);
                const warehouse = parseInt(el.getAttribute("data-warehouse-id"));

                if (isNaN(quantity) || isNaN(warehouse)) {
                    return;
                }

                data.stock.push({warehouse, quantity});
            });

            const form = document.getElementById("itemSaveForm");

            fetch(form.action, {
                method: form.method,
                body: JSON.stringify(data),
                headers: {
                    'Accept': 'application/json, text/plain, */*',
                    'Content-Type': 'application/json'
                },
            }).then(response => {
                if (!response.ok) {
                    throw new Error(`${response.status}`);
                }
            }).then(() => {
                Snackbar.show({
                    text: "Saved successfully!"
                });
            }).catch(e => {
                Snackbar.show({
                    text: `${e}`
                });
            });
        });
    }

    document.querySelectorAll("button.removePriceRangeBtn").forEach(btn => {
        bindClickToPriceRange(btn)
    });

    function addCartBtnClick(btn) {
        const modal = document.getElementById("add-cart-modal");
        const li = btn.closest("li");
        const item = li.cloneNode(true);
        const body = modal.querySelector(".modal-body");
        const input = document.createElement("input");
        const price = item.querySelector(".item-price");
        const totalPrice = price.cloneNode();

        const priceRanges = JSON.parse(li.dataset.priceRanges).sort((a, b) => {
            return a.minQuantity - b.minQuantity;
        });

        const minQuantity = priceRanges[0].minQuantity;

        li.id = "add-cart-item"
        totalPrice.className = "my-0 ml-2 text-right";
        totalPrice.style.width = "75px";
        price.className = "my-0 mx-2";
        input.type = "number";
        input.placeholder = minQuantity;
        input.className = "form-control ml-2 text-center";
        input.style.maxWidth = "75px";
        input.min = minQuantity;
        input.id = "add-quantity";
        input.value = minQuantity;
        totalPrice.textContent = `$${Math.ceil(priceRanges[0].price * minQuantity * 100) / 100}`;

        item.querySelector("button").replaceWith(input);

        input.insertAdjacentHTML("beforebegin", "&times;");
        price.parentNode.appendChild(totalPrice);

        input.addEventListener("input", e => {
            const value = e.target.value;
            if (value === "") {
                return;
            }

            const parsedValue = parseInt(value);
            if (isNaN(parsedValue)) {
                e.target.value = "";
                return;
            }

            if (parsedValue < 1) {
                e.target.value = 1;
                return;
            }

            let range;
            for (let r of priceRanges) {
                if (r.minQuantity <= parsedValue) {
                    range = r;
                }
            }

            price.textContent = `$${range.price}`;
            totalPrice.textContent = `$${Math.ceil(range.price * parsedValue * 100) / 100}`;
        })

        body.replaceChild(item, body.querySelector("li"));
        $('#add-cart-modal').modal('show');
    }

    document.querySelectorAll("button.shopping-cart-add").forEach(btn => {
        btn.addEventListener("click", () => {
            addCartBtnClick(btn);
        });
    });

    const addCartBtnFinal = document.getElementById("add-cart-button");
    if (addCartBtnFinal !== null) {
        addCartBtnFinal.addEventListener("click", () => {
            const li = document.getElementById("add-cart-item");
            const itemId = li.dataset.itemId;
            const quantity = parseInt(document.getElementById("add-quantity").value) || 0;

            fetch("/user/store/cart", {
                method: "POST",
                body: JSON.stringify({
                    itemId,
                    quantity
                }),
                headers: {
                    'Accept': 'application/json, text/plain, */*',
                    'Content-Type': 'application/json'
                },
            }).then(response => {
                if (!response.ok) {
                    throw new Error(`${response.status}`);
                }
            }).then(() => {
                window.location.reload();
            }).catch(e => {
                Snackbar.show({
                    text: `${e}`
                });
            });
        });
    }

    const clearCartBtn = document.getElementById("cart-clear-btn");
    if (clearCartBtn !== null) {
        clearCartBtn.addEventListener("click", () => {
            fetch("/user/store/cart", {method: "DELETE"});
            window.location.reload();
        })
    }
});