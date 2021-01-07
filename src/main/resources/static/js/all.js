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

    document.getElementById("addPriceRangeBtn").addEventListener("click", () => {
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

    document.getElementById("saveItem").addEventListener("click", () => {
        const rangeList = document.querySelectorAll("#priceRangeList > .priceRange")
        const data = {
            priceRanges: [],
            stock: []
        }

        rangeList.forEach(el => {
            const minQuantity = parseInt(el.querySelector("input.priceRangeQuantity").value);
            const price = parseFloat(el.querySelector("input.priceRangePrice").value);

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

    document.querySelectorAll("button.removePriceRangeBtn").forEach(btn => {
        bindClickToPriceRange(btn)
    });
});