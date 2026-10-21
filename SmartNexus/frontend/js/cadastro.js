/* =====================================================
   Página de cadastro
   - envia razão social, CNPJ, e-mail e telefone para POST /api/usuarios
   - os nomes dos campos são os mesmos das colunas da tabela "usuario"
   ===================================================== */
(function () {
    const form = document.getElementById("form-cadastro");
    const msg = document.getElementById("msg-cadastro");
    const botao = form.querySelector("button[type=submit]");

    function mascaraTelefone(valor) {
        const n = valor.replace(/\D/g, "").slice(0, 11);
        if (n.length <= 2) return n;
        if (n.length <= 6) return `(${n.slice(0, 2)}) ${n.slice(2)}`;
        if (n.length <= 10) return `(${n.slice(0, 2)}) ${n.slice(2, 6)}-${n.slice(6)}`;
        return `(${n.slice(0, 2)}) ${n.slice(2, 7)}-${n.slice(7)}`;
    }

    function mascaraCnpj(valor) {
        const n = valor.replace(/\D/g, "").slice(0, 14);
        return n
            .replace(/^(\d{2})(\d)/, "$1.$2")
            .replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3")
            .replace(/\.(\d{3})(\d)/, ".$1/$2")
            .replace(/(\d{4})(\d)/, "$1-$2");
    }

    form.elements["telefone"].addEventListener("input", (e) => {
        e.target.value = mascaraTelefone(e.target.value);
    });
    form.elements["cnpj"].addEventListener("input", (e) => {
        e.target.value = mascaraCnpj(e.target.value);
    });

    form.addEventListener("submit", async (e) => {
        e.preventDefault();
        msg.textContent = "";

        const dados = {
            razao_social: form.elements["razao_social"].value.trim(),
            cnpj: form.elements["cnpj"].value.trim(),
            email: form.elements["email"].value.trim(),
            telefone: form.elements["telefone"].value.trim(),
        };

        if (Object.values(dados).some((v) => !v)) {
            msg.textContent = "Preencha todos os campos.";
            return;
        }
        if (dados.cnpj.replace(/\D/g, "").length !== 14) {
            msg.textContent = "Digite o CNPJ completo (14 números).";
            return;
        }

        botao.disabled = true;
        try {
            const resposta = await fetch("/api/usuarios", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(dados),
            });
            const corpo = await resposta.json().catch(() => ({}));

            if (!resposta.ok) {
                const detalhes = Array.isArray(corpo.detalhes) ? " " + corpo.detalhes.join(" ") : "";
                msg.textContent = (corpo.erro || "Não foi possível criar a conta.") + detalhes;
                botao.disabled = false;
                return;
            }
            window.location.href = "planos.html";
        } catch (erro) {
            msg.textContent = "Não foi possível falar com o servidor. Abra o site pelo endereço do Flask (http://127.0.0.1:5000).";
            botao.disabled = false;
        }
    });
})();
