Rails.application.routes.draw do
  
  get 'projekty/new'

  get 'szafki/new'

  get 'uzytkownicy/index'

  get 'odzyskaj_haslo/:id/*salt', to: 'uzytkownicy#odzyskaj_haslo', as: 'odzyskaj_haslo'

  post 'uzytkownicy/nowe_haslo'

  post 'uzytkownicy/lista'
   
  get'uzytkownicy/lista'


  post 'uzytkownicy/pobierz'

  get 'uzytkownicy/zapomnialem'

  post 'uzytkownicy/zmien_haslo'

  post 'uzytkownicy/zaladuj'

  get 'uzytkownicy/administracja'

  get 'projekty/index'

  post 'projekty/create'

  post 'projekty/usun_przedmiot'

  post 'projekty/dodaj_uzytkownika'

  post 'projekty/edytuj_role'

  post 'projekty/zmien_role'

  post 'projekty/usun_uzytkownika'

  post 'projekty/dodaj_osobe'

  delete 'projekty/destroy'
 
  patch 'projekty/status_czlonka' 

  get 'projekty', to: 'projekty#index', as: 'projekty'

  get 'projekty/show'

  post 'projekty/umiesc_w_szafce'

  post 'projekty/schowaj_do_szafki'

  get 'projekty/:id', to: 'projekty#show'

  get 'projekty/:id/edit', to: 'projekty#edit', as: 'projekty_edit'

  patch 'projekty/:id/edit', to: 'projekty#update'

  delete 'projekty.:id', to: 'projekty#destroy'

  get 'szafki/index'

  post 'szafki/index'

  get 'szafki', to: 'szafki#index'

  get 'szafki/show'

  get 'szafki/edit'

  patch 'szafki/edit', to: 'szafki#update'

  post 'szafki/create'

  post 'szafki/schowaj'



  get 'szafki/:id', to: 'szafki#show'

  get 'szafki/:id/edit', to: 'szafki#edit'

  patch 'szafki/:id/edit', to: 'szafki#update'

  delete 'szafki', to: 'szafki#destroy'

  post 'szafki/zwroc_przedmioty'

  post 'przedmioty/wyczysc'

  get 'przedmioty/index'  

  get 'przedmioty/show'
  
  post 'przedmioty/wybierz/:id', to: 'przedmioty#wybierz', as: 'przedmioty_wybierz' 
  
  get 'przedmioty/edit'

  get 'przedmioty/new'

  get 'przedmioty/update'

  post 'przedmioty/create'

  get 'przedmioty/grupuj'

  post 'przedmioty/dodaj_do_projektu'

  post 'przedmioty/dodaj_do_projektu_A'

  post 'przedmioty/wypozycz'

  post 'przedmioty/schowaj'

  post 'przedmioty/schowaj_A'

  post 'uzytkownicy/resetuj_haslo'  
	
  post 'uzytkownicy/kopia'



  delete 'przedmioty.:id', to: 'przedmioty#destroy'

  delete 'przedmioty/destroy_all'

  get 'przedmioty', to: 'przedmioty#index'

  get 'przedmioty/:id', to: 'przedmioty#show'

  get 'przedmioty/:id/edit', to: 'przedmioty#edit'

  patch 'przedmioty/edit', to: 'przedmioty#update'

  patch 'przedmioty/edit.:id', to: 'przedmioty#update'

  get 'uzytkownicy/logowanie'

  get 'uzytkownicy/wyloguj'

  get 'uzytkownicy/rejestracja'

  get '/rejestracja' , to: 'uzytkownicy#rejestracja'

  delete 'uzytkownicy.:id', to: 'uzytkownicy#destroy'

  post 'uzytkownicy/zaloguj'

  get 'uzytkownicy/:id', to: 'uzytkownicy#show'

  get 'uzytkownicy/:id/edit', to: 'uzytkownicy#edit'

  patch 'uzytkownicy/:id/edit', to: 'uzytkownicy#update'
  #put 'uzytkownicy/:id', to: 'uzytkownicy#update'

  post 'uzytkownicy/zarejestruj'

  get 'uzytkownicy', to: 'uzytkownicy#index'

  get 'administracja', to: 'uzytkownicy#administracja'

  post 'administruj.:id', to: 'uzytkownicy#administruj'

  delete 'administruj.:id', to: 'uzytkownicy#administruj_odrzuc'

  get 'root/index'


  root 'root#index'
end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
