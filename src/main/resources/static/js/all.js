document.addEventListener("DOMContentLoaded", () => {
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
})