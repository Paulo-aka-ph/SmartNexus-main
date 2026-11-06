/* =====================================================
   Página de planos
   - o HTML já traz os preços (funciona mesmo sem servidor)
   - ao carregar, busca GET /api/planos e atualiza o preço de cada card
     pelo data-plano-id, para o banco ser a fonte do valor
   ===================================================== */
(function () {
    const reais = (n) => "R$ " + Number(n).toLocaleString("pt-BR", { maximumFractionDigits: 0 });

    fetch("/api/planos")
        .then((r) => (r.ok ? r.json() : Promise.reject()))
        .then((planos) => {
            planos.forEach((p) => {
                const card = document.querySelector(`.card-plano[data-plano-id="${p.plano_id}"]`);
                const preco = card && card.querySelector(".plano-preco");
                if (!preco) return;
                // mantém o <small>a partir de</small> e troca só o valor
                preco.lastChild.textContent = " " + reais(p.preco_base);
            });
        })
        .catch(() => { /* sem servidor/banco: continua com os valores do HTML */ });
})();
