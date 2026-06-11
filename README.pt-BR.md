# ShowcaseApp
Apenas um demonstrador para recrutadores

> 🇬🇧 [English version](README.md)

Um app de showcase em SwiftUI que demonstra a integração, em nível sênior, de seis frameworks da Apple em torno da **iTunes Search API** pública. Busque no catálogo de músicas, toque os previews de 30 segundos com um engine de áudio próprio e um visualizador animado, salve favoritos que persistem entre sessões, e receba resultados localizados pela sua região.

![iOS](https://img.shields.io/badge/iOS-26%2B-black)
![Swift](https://img.shields.io/badge/Swift-6.2-orange)
![Xcode](https://img.shields.io/badge/Xcode-26-blue)
![UI](https://img.shields.io/badge/UI-SwiftUI-green)

---

## O que o app faz

| Tela | Descrição |
| --- | --- |
| **Busca** | Pesquisa reativa e com debounce no catálogo da iTunes, com resultados em capa. |
| **Player** | Toca o preview de áudio de 30s com um engine AVFoundation próprio e um equalizador em Core Animation que reage ao playback. |
| **Favoritos** | Favoritos persistidos com swipe-to-delete, em aba própria. |

O app **não usa chaves de API**, a iTunes Search API é keyless. Isso é uma escolha deliberada: quem for avaliar o projeto clona e roda na hora, sem nenhuma fricção de configuração.

---

## Frameworks, e o que cada um demonstra

- **SwiftUI**: UI declarativa, `NavigationStack` com navegação por valor, semântica de posse `@StateObject`/`@ObservedObject`, `AsyncImage` com tratamento de `phase`, `ContentUnavailableView` para estados vazios/de erro, `.searchable`, `TabView`.
- **Swift Concurrency (6.2)**: rede com `async`/`await`, **isolamento padrão por MainActor**, uma camada de dados `nonisolated`, ponte de callbacks para async com `CheckedContinuation`, e `MainActor.assumeIsolated` para closures com garantia de main thread em tempo de execução.
- **Combine**: pipeline de busca com debounce (`debounce` + `removeDuplicates`) e publishers de KVO (`publisher(for:)`) para observar o estado do `AVPlayer`.
- **AVFoundation**: um engine `AVPlayer` próprio, configuração de `AVAudioSession`, um periodic time observer para o progresso e observação de `timeControlStatus`.
- **Core Animation**: um equalizador feito com `CAReplicatorLayer` + `CABasicAnimation`, hospedado no SwiftUI via `UIViewRepresentable`.
- **Core Data**: persistência de favoritos com `@FetchRequest`, `@Environment(\.managedObjectContext)` e buscas com `NSPredicate`.
- **Core Location + MapKit**: a loja regional derivada da localização do device via reverse geocoding, com degradação graciosa.

---

## Arquitetura

- **MVVM.** Os view models são `@MainActor final class … ObservableObject` com saídas `@Published`.
- **Isolamento em camadas.** A camada de dados/rede (`NetworkService`, modelos `Codable`) é `nonisolated`; a camada de UI (view models, views) é `@MainActor`. Isso espelha como bases de código reais adotam o modelo main-actor-por-padrão do Swift 6.2.
- **Pontos de injeção de dependência.** O `NetworkService` é injetado no view model de busca com valor padrão, conveniente de usar, fácil de mockar em testes.

```
Fluxo de busca:  TextField → @Published searchText → Combine (debounce) → Task → URLSession async → Codable → @Published tracks → List
```

---

## Decisões de engenharia (o "porquê")

- **Fronteira async/await vs Combine.** O Combine governa eventos *contínuos* (o texto de busca ao longo do tempo, o tempo de playback); o async/await governa operações *pontuais* (a requisição de rede). A ponte entre os dois é uma `Task` aberta dentro do `sink` do Combine.
- **Isolamento padrão por MainActor.** No Swift 6.2, todo tipo é implicitamente `@MainActor`, salvo marcação contrária. A camada de UI mantém esse padrão; a camada de dados opta por sair com `nonisolated`, para que rede e parsing não rodem no main actor e possam cruzar fronteiras de actor livremente.
- **Áudio, não vídeo.** Os previews de música da iTunes são áudio (`.m4a`), então não há camada de vídeo para renderizar, o `AVPlayerLayer` seria um retângulo vazio. A profundidade de AVFoundation vem do engine de player (asset/item/player, sessão de áudio, time observers). O visualizador é **decorativo**; um analisador de espectro de verdade faria um tap no áudio com `AVAudioEngine` e rodaria uma FFT.
- **Deprecação do iOS 26.** O `CLGeocoder` foi aposentado em favor do `MKReverseGeocodingRequest` do MapKit, que devolve o *nome* do país em vez do código ISO. O nome é convertido em código ISO via `Locale`, com `Locale.current.region` como fallback.
- **Degradação graciosa.** A região da loja começa instantaneamente pelo locale do device (sem permissão nenhuma) e é *refinada* por GPS só se o usuário autorizar a localização. Negue a permissão e o app continua funcionando, só fica menos preciso.
- **Ciclo de vida do TabView.** `onAppear`/`onDisappear` disparam em troca de aba, não só em push/pop. Por isso o engine de player é idempotente e distingue "pausar" (aba escondida) de "destruir" (tela retirada da pilha).
- **Core Data em vez de SwiftData, de propósito.** Domino os dois; usar Core Data aqui amplia o stack demonstrado.

---

## Requisitos

- iOS 26+ / Xcode 26 / Swift 6.2
- Build setting **Default Actor Isolation = MainActor** (o padrão do Xcode 26)
- Chave de `Info` **`NSLocationWhenInUseUsageDescription`** (necessária para a loja regional)

---

## Como rodar

1. Clone o repositório.
2. Abra o projeto no Xcode 26.
3. Rode no simulador ou device. Sem chaves, sem `.env`, sem configuração.

Para validar a sessão de áudio, rode num device físico com a chave de silencioso ligada, o preview deve tocar mesmo assim.

---

## Autora

**Camile Ancines** - desenvolvedora iOS.
